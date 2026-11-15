/*
 * Dispute handling for destination charges.
 *
 * TagAlong takes the passenger's money as a destination charge: the platform
 * is the merchant of record, and the driver's share is transferred to their
 * connected account at the moment of the charge. When a passenger disputes a
 * ride, Stripe debits the disputed amount *and* the dispute fee from the
 * platform balance, not the driver's. Recovering the driver's share is not
 * automatic - unlike a refund, where `reverse_transfer: true` does it for us -
 * and needs an explicit transfer reversal.
 *
 * Timing follows Stripe's guidance: reverse only once a dispute is actually
 * lost. Reversing early and then winning means transferring the money back,
 * which can fail outright on an insufficient platform balance.
 *
 * The lever that makes this work is the manual payout schedule. Driver funds
 * sit in their Stripe balance until markRidePaid releases them, so withholding
 * a disputed fare keeps it reversible. Reversing a transfer whose money has
 * already reached the driver's bank just drives their balance negative, and
 * recovery then depends on `debit_negative_balances`.
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
 * Nothing is reversed here. The money stays in the driver's Stripe balance,
 * which is exactly where it needs to be if the dispute is later lost.
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

  const charge = await stripe().charges.retrieve(dispute.charge);
  const transferId = typeof charge.transfer === "string" ?
    charge.transfer :
    charge.transfer && charge.transfer.id;

  if (!transferId) {
    // No transfer means the driver never received this money, so there is
    // nothing to recover. The platform absorbs it.
    logger.warn("Lost dispute has no transfer to reverse", {
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
