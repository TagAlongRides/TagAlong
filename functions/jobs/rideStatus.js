const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const {stripe} = require("../lib/stripe");
const {payDrivers} = require("../lib/payouts");

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
