/*
 * Paying drivers.
 *
 * A passenger's fare is charged in full to TagAlong's own Stripe balance when
 * they book (see the booking route in routes/payment.js). Nothing reaches the
 * driver at that point. Once a day this module moves each driver's share of
 * the rides completed before today out to them: one transfer from TagAlong to
 * the driver's connected account, then one payout from that account to their
 * bank, covering every fare that is ready.
 *
 * Every step is recorded in a `payoutBatches` document *before* money moves,
 * and each Stripe call can be found again from that record. That is what makes
 * a rerun safe: a run that dies between creating a transfer and recording it
 * finds the transfer by its transfer group the next day instead of sending a
 * second one. Stripe idempotency keys alone are not enough here, because they
 * expire after 24 hours and the job's retry is a day later.
 *
 * Bookings made before this flow existed were destination charges, whose
 * driver share was transferred at the moment of the charge. Those are
 * recognised by the payment intent's `transfer_data` and included in the
 * payout without being transferred a second time.
 */
const logger = require("firebase-functions/logger");
const {isWithheld} = require("./disputes");
const {parseCents} = require("./amount");
const {departedBy} = require("./departure");

/** The day boundary drivers are paid on. */
const TIME_ZONE = "America/New_York";

/** Marks a payment intent as charged under this flow. */
const FUNDS_FLOW = "platform_hold";

const BATCHES = "payoutBatches";

/** `YYYY-MM-DD` for `date` in Eastern time. */
function easternDate(date) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TIME_ZONE, year: "numeric", month: "2-digit", day: "2-digit",
  }).format(date);
}

/**
 * What a booking's driver is owed, worked out from its payment intent.
 *
 * Returns `{cents, mode}` where mode is "transfer" (the money is in
 * TagAlong's balance and must be transferred) or "legacy" (a destination
 * charge, already in the driver's Stripe balance), or `{error}` when the
 * booking cannot be paid safely and needs a person to look at it.
 */
async function driverShare(stripe, booking, ride) {
  if (!booking.paymentIntentId) {
    return {error: "booking has no payment intent"};
  }
  const intent = await stripe.paymentIntents.retrieve(booking.paymentIntentId);
  if (intent.status !== "succeeded") {
    return {error: `payment intent is ${intent.status}`};
  }

  if (intent.transfer_data && intent.transfer_data.destination) {
    if (intent.transfer_data.destination !== ride.stripe_account_id) {
      return {error: "destination charge went to a different account than the ride's driver"};
    }
    return {cents: intent.amount - (intent.application_fee_amount || 0), mode: "legacy"};
  }

  const metadata = intent.metadata || {};
  if (metadata.funds_flow !== FUNDS_FLOW) {
    return {error: "payment intent was not charged by the booking route"};
  }
  if (metadata.driver_account !== ride.stripe_account_id) {
    // Never pay a fare to an account other than the one it was charged for.
    return {error: "payment intent names a different driver account than the ride"};
  }
  const cents = parseCents(metadata.driver_share_cents);
  if (cents === null || cents > intent.amount) {
    return {error: `driver_share_cents is unusable (${metadata.driver_share_cents})`};
  }
  return {cents, mode: "transfer"};
}

/**
 * Pays every driver who is owed money for rides completed before today.
 *
 * @param {object} deps
 * @param {FirebaseFirestore.Firestore} deps.db
 * @param {import("stripe").Stripe} deps.stripe
 * @param {Date} [deps.now]
 * @param {string[]} [deps.rideIds] only consider these rides (`ride_id`), for
 *   paying out by hand. Omit to consider every completed ride.
 * @param {boolean} [deps.dryRun] work out who would be paid what and return
 *   it as `counts.plan`, without writing anything or moving any money.
 * @returns {Promise<object>} counts for the job log
 */
async function payDrivers({db, stripe, now = new Date(), rideIds, dryRun = false}) {
  const counts = {drivers: 0, bookings: 0, cents: 0, withheld: 0, waiting: 0, skipped: 0, failed: 0};
  const inScope = (rideId) => !rideIds || rideIds.includes(rideId);
  if (dryRun) counts.plan = {pendingBatches: [], newBatches: []};

  // Finish anything an earlier run started first. Those bookings are already
  // claimed by their batch, so they are not picked up again below.
  const pending = await db.collection(BATCHES).where("status", "==", "pending").get();
  for (const doc of pending.docs) {
    const batch = doc.data();
    if (!Object.values(batch.shares || {}).some((share) => inScope(share.rideId))) continue;
    if (dryRun) {
      counts.plan.pendingBatches.push({id: doc.id, ...batch});
      continue;
    }
    await settleBatch({db, stripe, ref: doc.ref, batch, counts});
  }

  const today = easternDate(now);
  const owed = new Map(); // driver account -> [{ride, rideRef, booking, bookingRef}]

  const rides = await db.collection("rides").where("status", "==", "complete").get();
  for (const rideDoc of rides.docs) {
    const ride = rideDoc.data();
    if (!inScope(ride.ride_id)) continue;
    const departed = departedBy(ride);
    if (!departed || easternDate(departed) >= today) {
      counts.waiting++;
      continue;
    }

    const bookings = await db.collection("rideBooking")
        .where("rideId", "==", ride.ride_id)
        .where("status", "==", "complete")
        .get();

    if (bookings.empty) {
      // Nobody rode, so nothing is owed. Close it so it isn't looked at again.
      if (!dryRun) await rideDoc.ref.update({status: "paid"});
      continue;
    }

    for (const bookingDoc of bookings.docs) {
      const booking = bookingDoc.data();
      if (booking.payoutBatchId) continue; // claimed by a batch already
      if (isWithheld(booking)) {
        counts.withheld++;
        continue;
      }
      const list = owed.get(ride.stripe_account_id) || [];
      list.push({ride, rideRef: rideDoc.ref, booking, bookingRef: bookingDoc.ref, bookingId: bookingDoc.id});
      owed.set(ride.stripe_account_id, list);
    }

    // A ride whose remaining fares were all lost to disputes has nothing left
    // to pay, and never will.
    if (!dryRun && bookings.docs.every((b) => b.data().disputeStatus === "lost")) {
      await rideDoc.ref.update({status: "paid"});
    }
  }

  for (const [account, items] of owed) {
    const shares = {};
    for (const item of items) {
      const share = await driverShare(stripe, item.booking, item.ride);
      if (share.error) {
        counts.skipped++;
        logger.error("Not paying a booking; needs manual review", {
          bookingId: item.bookingId, rideId: item.ride.ride_id, account, reason: share.error,
        });
        continue;
      }
      shares[item.bookingId] = {cents: share.cents, mode: share.mode, rideId: item.ride.ride_id};
    }
    if (Object.keys(shares).length === 0) continue;

    if (dryRun) {
      counts.plan.newBatches.push({account, payoutDate: today, shares, ...totals(shares)});
      continue;
    }

    const ref = db.collection(BATCHES).doc();
    const batch = {
      account,
      payoutDate: today,
      status: "pending",
      createdAt: now.getTime(),
      shares,
      ...totals(shares),
      transferId: null,
      payoutId: null,
    };

    // Claim the bookings and record the batch in one write, so a booking can
    // never end up in two batches.
    const write = db.batch();
    write.set(ref, batch);
    for (const item of items) {
      if (shares[item.bookingId]) write.update(item.bookingRef, {payoutBatchId: ref.id});
    }
    await write.commit();

    await settleBatch({db, stripe, ref, batch, counts});
  }

  return counts;
}

function totals(shares) {
  let transferCents = 0;
  let payoutCents = 0;
  for (const share of Object.values(shares)) {
    payoutCents += share.cents;
    if (share.mode === "transfer") transferCents += share.cents;
  }
  return {transferCents, payoutCents};
}

/**
 * Moves one batch's money: transfer, then payout. Safe to call again on a
 * batch that got partway; each step is skipped once it is recorded, and
 * looked up on Stripe before being created.
 */
async function settleBatch({db, stripe, ref, batch, counts}) {
  const batchId = ref.id;
  try {
    if (!batch.transferId && batch.transferCents > 0) {
      // Until the transfer exists, a fare can still drop out - a dispute may
      // have opened, or the passenger cancelled, since the batch was made.
      batch = await recheckBatch({db, ref, batch});
      if (Object.keys(batch.shares).length === 0) {
        await ref.update({status: "empty"});
        return;
      }
    }

    if (!batch.transferId && batch.transferCents > 0) {
      const existing = await stripe.transfers.list({transfer_group: batchId, limit: 1});
      const transfer = existing.data[0] || await stripe.transfers.create({
        amount: batch.transferCents,
        currency: "usd",
        destination: batch.account,
        transfer_group: batchId,
        description: `TagAlong rides completed before ${batch.payoutDate}`,
        metadata: {payout_batch_id: batchId},
      }, {idempotencyKey: `transfer_${batchId}`});
      batch.transferId = transfer.id;
      await ref.update({transferId: transfer.id});
    }

    if (!batch.payoutId) {
      const payout = await findPayout(stripe, batch, batchId) || await stripe.payouts.create({
        amount: batch.payoutCents,
        currency: "usd",
        description: `TagAlong rides completed before ${batch.payoutDate}`,
        metadata: {payout_batch_id: batchId},
      }, {stripeAccount: batch.account, idempotencyKey: `payout_${batchId}`});
      batch.payoutId = payout.id;
      await ref.update({payoutId: payout.id, status: "paid"});
    }

    await markPaid({db, batch, batchId});

    counts.drivers++;
    counts.bookings += Object.keys(batch.shares).length;
    counts.cents += batch.payoutCents;
    logger.info("Paid driver", {
      batchId, account: batch.account, cents: batch.payoutCents,
      transferId: batch.transferId, payoutId: batch.payoutId,
    });
  } catch (error) {
    // The batch stays pending and is finished on the next run. One driver
    // failing must not hold up anyone else.
    counts.failed++;
    logger.error("Driver payout failed; will retry next run", {
      batchId, account: batch.account,
      detail: error && error.message, stripeCode: error && error.code,
    });
  }
}

/** Drops fares that became unpayable after the batch was made. */
async function recheckBatch({db, ref, batch}) {
  const shares = {};
  const released = [];
  for (const [bookingId, share] of Object.entries(batch.shares)) {
    const snapshot = await db.collection("rideBooking").doc(bookingId).get();
    const booking = snapshot.data();
    if (booking && booking.status === "complete" && !isWithheld(booking)) {
      shares[bookingId] = share;
    } else {
      released.push(bookingId);
    }
  }
  if (released.length === 0) return batch;

  for (const bookingId of released) {
    await db.collection("rideBooking").doc(bookingId).update({payoutBatchId: null});
  }
  const updated = {...batch, shares, ...totals(shares)};
  await ref.update({shares, transferCents: updated.transferCents, payoutCents: updated.payoutCents});
  logger.info("Dropped fares from a payout batch before transferring", {batchId: ref.id, released});
  return updated;
}

/** A payout this batch already created, if a crash kept it from being recorded. */
async function findPayout(stripe, batch, batchId) {
  const recent = await stripe.payouts.list(
      {created: {gte: Math.floor(batch.createdAt / 1000) - 60}, limit: 100},
      {stripeAccount: batch.account},
  );
  return recent.data.find((payout) => (payout.metadata || {}).payout_batch_id === batchId) || null;
}

/** Marks the batch's bookings paid, and closes rides with nothing left owed. */
async function markPaid({db, batch, batchId}) {
  const rideIds = new Set();
  for (const [bookingId, share] of Object.entries(batch.shares)) {
    await db.collection("rideBooking").doc(bookingId).update({status: "paid", payoutBatchId: batchId});
    rideIds.add(share.rideId);
  }

  for (const rideId of rideIds) {
    const remaining = await db.collection("rideBooking")
        .where("rideId", "==", rideId)
        .where("status", "==", "complete")
        .get();
    // Fares still under an open dispute, or released by a won one, keep the
    // ride open so they can be paid later. Lost fares are terminal.
    if (remaining.docs.every((b) => b.data().disputeStatus === "lost")) {
      const rides = await db.collection("rides").where("ride_id", "==", rideId).get();
      for (const ride of rides.docs) await ride.ref.update({status: "paid"});
    }
  }
}

module.exports = {payDrivers, driverShare, easternDate, FUNDS_FLOW, TIME_ZONE};
