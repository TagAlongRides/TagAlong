const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const {stripe} = require("../lib/stripe");

/**
 * How long after departure a completed ride waits before the driver is paid,
 * leaving room for disputes and cancellations.
 */
const COOL_OFF_DAYS = 2;

/** Appends a line to the scheduleJob audit collection. */
async function log(job, message) {
  logger.info(`${job}: ${message}`);
  await admin.firestore().collection("scheduleJob").add({
    time: Date.now(),
    log: `${job} - ${message}`,
  });
}

/**
 * Marks rides complete once their departure time has passed.
 *
 * Both this and [markRidePaid] previously took `(req, res, context)` and
 * finished with `res.send(...)`, but a scheduled function is only ever handed
 * an event — so `res` was undefined and every single run ended in a
 * TypeError. The Firestore writes had already happened by then, so the work
 * was done, but each invocation was recorded as a failure.
 */
async function markRideComplete() {
  const db = admin.firestore();
  const rides = await db.collection("rides").where("status", "==", "scheduled").get();

  if (rides.empty) {
    await log("markRideComplete", "No scheduled rides found");
    return;
  }

  let completed = 0;
  let waiting = 0;

  await Promise.all(rides.docs.map(async (doc) => {
    const ride = doc.data();
    const departure = ride.departure_date_time.toDate();

    if (Date.now() < departure) {
      waiting++;
      return;
    }

    const bookings = await db
        .collection("rideBooking")
        .where("rideId", "==", ride.ride_id)
        .where("status", "==", "active")
        .get();

    await Promise.all(bookings.docs.map((booking) => booking.ref.update({status: "complete"})));
    await doc.ref.update({status: "complete"});
    completed++;
  }));

  await log("markRideComplete", `${completed} ride(s) completed, ${waiting} not yet departed`);
}

/**
 * Pays drivers for rides that have cleared the cool-off period.
 *
 * Connected accounts are created with a manual payout schedule, so the money
 * sits in the driver's Stripe balance until this job releases it.
 */
async function markRidePaid() {
  const db = admin.firestore();
  const rides = await db.collection("rides").where("status", "==", "complete").get();

  if (rides.empty) {
    await log("markRidePaid", "No completed rides found");
    return;
  }

  let paid = 0;
  let waiting = 0;
  let failed = 0;

  await Promise.all(rides.docs.map(async (doc) => {
    const ride = doc.data();
    const departure = ride.departure_date_time.toDate();
    const daysSince = (Date.now() - departure) / (1000 * 60 * 60 * 24);

    if (daysSince <= COOL_OFF_DAYS) {
      waiting++;
      return;
    }

    const bookings = await db
        .collection("rideBooking")
        .where("rideId", "==", ride.ride_id)
        .where("status", "==", "complete")
        .get();

    if (bookings.empty) {
      // Nobody rode, so there is nothing to pay out. Close the ride off so it
      // isn't reconsidered on every subsequent run.
      await doc.ref.update({status: "paid"});
      return;
    }

    const amount = bookings.size * ride.price;

    try {
      const payout = await stripe().payouts.create(
          {amount: amount * 100, currency: "usd"},
          {stripeAccount: ride.stripe_account_id},
      );

      await Promise.all(bookings.docs.map((booking) => booking.ref.update({status: "paid"})));
      await doc.ref.update({status: "paid"});

      paid++;
      logger.info(`Ride ${ride.ride_id} paid out $${amount} (${payout.id})`);
    } catch (error) {
      // One driver's payout failing must not abandon the rest. The ride stays
      // "complete" and will be retried on the next run.
      failed++;
      logger.error(`Payout failed for ride ${ride.ride_id}`, error);
    }
  }));

  await log("markRidePaid", `${paid} paid, ${waiting} in cool-off, ${failed} failed`);
}

module.exports = {markRideComplete, markRidePaid};
