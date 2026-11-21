/*
 * Dispute handling.
 *
 * TagAlong charges the passenger's full fare to its own Stripe balance and
 * pays drivers once a day for completed rides (lib/payouts.js). Stripe debits
 * a disputed amount and the dispute fee from TagAlong's balance either way.
 *
 * - Disputed before the driver is paid (the usual case): the fare is withheld
 *   from payout while the dispute is open. If it is lost, the driver was never
 *   paid, so there is nothing to recover. If it is won, the next payout pays it.
 * - Disputed after the driver is paid: if lost, this fare's share is reversed
 *   out of the driver's payout transfer. Their money may already be in their
 *   bank, in which case the reversal drives their Stripe balance negative.
 * - Bookings from before the switch were destination charges, transferred at
 *   the moment of the charge; a lost dispute reverses that transfer, as before.
 *
 * Timing follows Stripe's guidance: reverse only once a dispute is actually
 * lost. Reversing early and then winning means transferring the money back.
 */
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const {stripe} = require("./stripe");

/** Dispute states in which a driver must not be paid. */
const WITHHOLDING_STATUSES = ["open", "lost"];

/**
 * The booking a dispute belongs to.
 *
 * Bookings record both ids at booking time, so either will do. The charge is
 * tried first because that is what a dispute is raised against.
 */
async function findBooking(db, dispute) {
  const candidates = [
    ["chargeId", dispute.charge],
    ["paymentIntentId", dispute.payment_intent],
  ];

  for (const [field, value] of candidates) {
    if (!value) continue;
    const snapshot = await db
        .collection("rideBooking")
        .where(field, "==", value)
        .limit(1)
        .get();
    if (!snapshot.empty) return snapshot.docs[0];
  }
  return null;
}

/**
 * A dispute was opened. Flag the booking so markRidePaid withholds the fare.
 *
 * Nothing is reversed here. While it is withheld the fare stays in TagAlong's
 * balance, which is exactly where it needs to be if the dispute is later lost.
 */
async function onDisputeCreated(db, dispute) {
  const booking = await findBooking(db, dispute);
  if (!booking) {
    logger.warn("Dispute does not match any booking", {
      disputeId: dispute.id,
      charge: dispute.charge,
    });
    return {handled: false, reason: "no matching booking"};
  }

  await booking.ref.update({
    disputeId: dispute.id,
    disputeStatus: "open",
    disputeAmount: dispute.amount,
    disputedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.info("Withholding payout for disputed booking", {
    bookingId: booking.id,
    disputeId: dispute.id,
    amount: dispute.amount,
  });
  return {handled: true, bookingId: booking.id, action: "withheld"};
}

/**
 * A dispute closed. Recover the driver's share if we lost it, release the
 * withheld payout if we won.
 */
async function onDisputeClosed(db, dispute) {
  const booking = await findBooking(db, dispute);
  if (!booking) {
    logger.warn("Closed dispute does not match any booking", {
      disputeId: dispute.id,
      charge: dispute.charge,
    });
    return {handled: false, reason: "no matching booking"};
  }

  const existing = booking.data();

  if (dispute.status === "won") {
    // The money was never taken from us. Clearing the flag lets the next
    // markRidePaid run pay the driver as normal.
    await booking.ref.update({
      disputeStatus: "won",
      disputeResolvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    logger.info("Dispute won; releasing withheld payout", {
      bookingId: booking.id,
      disputeId: dispute.id,
    });
    return {handled: true, bookingId: booking.id, action: "released"};
  }

  if (dispute.status !== "lost") {
    // warning_closed and similar: informational, nothing was debited.
    await booking.ref.update({disputeStatus: dispute.status});
    return {handled: true, bookingId: booking.id, action: "recorded"};
  }

  // Stripe redelivers events, so a reversal we already made must not be made
  // twice - that would claw back the driver's money a second time.
  if (existing.transferReversalId) {
    logger.info("Transfer already reversed for this dispute", {
      bookingId: booking.id,
      reversalId: existing.transferReversalId,
    });
    return {handled: true, bookingId: booking.id, action: "already reversed"};
  }

  // A fare charged to TagAlong's own balance reaches the driver only through
  // a daily payout batch. If its batch has transferred, take back exactly
  // this fare's share of that transfer - the rest of it is other rides.
  if (existing.payoutBatchId) {
    const batchDoc = await db.collection("payoutBatches").doc(existing.payoutBatchId).get();
    const batch = batchDoc.exists ? batchDoc.data() : null;
    const share = batch && batch.shares && batch.shares[booking.id];
    if (batch && batch.transferId && share && share.mode === "transfer") {
      const reversal = await stripe().transfers.createReversal(batch.transferId, {
        amount: share.cents,
        metadata: {booking_id: booking.id, dispute_id: dispute.id},
      }, {idempotencyKey: `dispute_reversal_${dispute.id}`});
      await booking.ref.update({
        disputeStatus: "lost",
        disputeResolvedAt: admin.firestore.FieldValue.serverTimestamp(),
        transferReversalId: reversal.id,
        transferReversedAmount: reversal.amount,
      });
      logger.info("Recovered driver share from their payout transfer after a lost dispute", {
        bookingId: booking.id,
        disputeId: dispute.id,
        transferId: batch.transferId,
        reversalId: reversal.id,
        amount: reversal.amount,
      });
      return {handled: true, bookingId: booking.id, action: "reversed", reversalId: reversal.id};
    }
  }

  const charge = await stripe().charges.retrieve(dispute.charge);
  const transferId = typeof charge.transfer === "string" ?
    charge.transfer :
    charge.transfer && charge.transfer.id;

  if (!transferId) {
    // No transfer means the driver never received this money - the normal
    // case now, since fares are held in TagAlong's balance until payout and
    // a disputed fare is withheld from it. Nothing to recover.
    logger.info("Lost dispute on a fare the driver was never paid", {
      bookingId: booking.id,
      disputeId: dispute.id,
      charge: dispute.charge,
    });
    await booking.ref.update({
      disputeStatus: "lost",
      disputeResolvedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {handled: true, bookingId: booking.id, action: "no transfer"};
  }

  // No amount: reverse whatever is left of the transfer. A partial reversal
  // would leave the driver holding part of a fare the passenger got back.
  const reversal = await stripe().transfers.createReversal(transferId);

  await booking.ref.update({
    disputeStatus: "lost",
    disputeResolvedAt: admin.firestore.FieldValue.serverTimestamp(),
    transferReversalId: reversal.id,
    transferReversedAmount: reversal.amount,
  });

  logger.info("Recovered driver share after a lost dispute", {
    bookingId: booking.id,
    disputeId: dispute.id,
    transferId,
    reversalId: reversal.id,
    amount: reversal.amount,
  });
  return {handled: true, bookingId: booking.id, action: "reversed", reversalId: reversal.id};
}

/** Whether a booking's fare is currently withheld from its driver. */
function isWithheld(booking) {
  return WITHHOLDING_STATUSES.includes((booking || {}).disputeStatus);
}

module.exports = {
  onDisputeCreated,
  onDisputeClosed,
  findBooking,
  isWithheld,
  WITHHOLDING_STATUSES,
};
