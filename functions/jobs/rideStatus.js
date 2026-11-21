const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const {stripe} = require("../lib/stripe");
const {payDrivers} = require("../lib/payouts");
const {departedBy} = require("../lib/departure");

/** Appends a line to the scheduleJob audit collection. */
async function log(job, message, db = admin.firestore()) {
  logger.info(`${job}: ${message}`);
  await db.collection("scheduleJob").add({
    time: Date.now(),
    log: `${job} - ${message}`,
  });
}

/**
 * Marks rides complete once their departure time has passed.
 *
 * "Departure" is the real moment the ride leaves (lib/departure.js), not
 * midnight of its day: completing a ride is what makes its driver payable, so
 * closing it at the start of the day would pay drivers for rides that hadn't
 * happened yet.
 *
 * Both this and [markRidePaid] previously took `(req, res, context)` and
 * finished with `res.send(...)`, but a scheduled function is only ever handed
 * an event — so `res` was undefined and every single run ended in a
 * TypeError. The Firestore writes had already happened by then, so the work
 * was done, but each invocation was recorded as a failure.
 */
async function markRideComplete({db = admin.firestore(), now = new Date()} = {}) {
  const rides = await db.collection("rides").where("status", "==", "scheduled").get();

  if (rides.empty) {
    await log("markRideComplete", "No scheduled rides found", db);
    return {completed: 0, waiting: 0, unreadable: 0};
  }

  let completed = 0;
  let waiting = 0;
  let unreadable = 0;

  await Promise.all(rides.docs.map(async (doc) => {
    const ride = doc.data();
    const departure = departedBy(ride);

    if (!departure) {
      // One malformed ride must not stop the others from being closed.
      logger.warn(`markRideComplete: ride ${doc.id} has no departure_date_time`);
      unreadable++;
      return;
    }
    if (now < departure) {
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

  await log("markRideComplete",
      `${completed} ride(s) completed, ${waiting} not yet departed, ${unreadable} unreadable`, db);
  return {completed, waiting, unreadable};
}

/**
 * The daily driver payout: every driver is paid, in one transfer and one
 * payout, for their rides completed before today (Eastern time). See
 * lib/payouts.js for how the money moves and why a rerun is safe.
 */
async function markRidePaid() {
  const c = await payDrivers({db: admin.firestore(), stripe: stripe()});
  await log("markRidePaid",
      `${c.drivers} driver(s) paid ${c.cents} cents for ${c.bookings} fare(s); ` +
      `${c.withheld} withheld for disputes, ${c.waiting} ride(s) not yet due, ` +
      `${c.skipped} need review, ${c.failed} failed`);
}

module.exports = {markRideComplete, markRidePaid};
