/**
 * TagAlong Cloud Functions.
 *
 * Replaces the Node 16 backend that lived outside this repository. Five
 * exports:
 *
 *  - `api`                 the payment API the app calls, now authenticated
 *  - `markRideComplete`    hourly, closes rides whose departure has passed
 *  - `markRidePaid`        hourly, releases driver payouts after cool-off
 *  - `onRideBooked`        pushes a notification to the driver (Milestone 4 §2.1)
 *  - `payments`            authorize / capture / release for the payment hold
 *                          (Milestone 4 §1.1 - §1.2, not yet wired to the app)
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

admin.initializeApp();

const {stripe, stripeSecretKey} = require("./lib/stripe");
const {requireAuth} = require("./lib/auth");
const paymentRoutes = require("./routes/payment");
const {markRideComplete, markRidePaid} = require("./jobs/rideStatus");

const db = admin.firestore();

// ------------------------------------------------------------------ The API

const app = express();
app.use(cors({origin: true}));
app.use(express.json());

// Everything below the mount point requires a valid Firebase ID token.
app.use("/v1/payment", requireAuth, paymentRoutes);

app.use((req, res) => {
  res.status(404).send({status: 404, success: false, message: `Unknown path ${req.path}`});
});

exports.api = onRequest({secrets: [stripeSecretKey]}, app);

// -------------------------------------------------------------- Scheduled

exports.markRideComplete = onSchedule(
    {schedule: "0 * * * *", timeZone: "America/New_York"},
    async () => {
      await markRideComplete();
    },
);

exports.markRidePaid = onSchedule(
    {schedule: "0 * * * *", timeZone: "America/New_York", secrets: [stripeSecretKey]},
    async () => {
      await markRidePaid();
    },
);

// ----------------------------------------------------------- Notifications

/** "Jordan P." — how we refer to people throughout the app. */
function firstNameLastInitial(user) {
  const first = (user && user.first_name) || "";
  const last = (user && user.last_name) || "";
  return last ? `${first} ${last.charAt(0)}.` : first;
}

/** The end of the trip that isn't campus is the one worth naming. */
function dropoffName(ride) {
  const dropoff = ride.dropoff_location || {};
  return dropoff.label || dropoff.city || "your destination";
}

function formatRideDate(ride) {
  const departure = ride.departure_date_time;
  if (!departure || typeof departure.toDate !== "function") {
    return "";
  }
  return departure.toDate().toLocaleDateString("en-US", {
    weekday: "long",
    month: "long",
    day: "numeric",
    timeZone: "America/New_York",
  });
}

/**
 * Notifies the driver that they have a new passenger.
 *
 * Failures are logged and swallowed — a missing device token must never roll
 * back a booking the passenger already paid for.
 */
exports.onRideBooked = onDocumentCreated("rideBooking/{bookingId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    return;
  }

  const booking = snapshot.data();
  if (!booking || booking.isCanceled) {
    return;
  }

  try {
    const rideQuery = await db
        .collection("rides")
        .where("ride_id", "==", booking.rideId)
        .limit(1)
        .get();

    if (rideQuery.empty) {
      logger.warn(`No ride found for booking ${snapshot.id}`);
      return;
    }
    const ride = rideQuery.docs[0].data();

    const [driverDoc, passengerDoc] = await Promise.all([
      db.collection("users").doc(ride.driver_id).get(),
      db.collection("users").doc(booking.userId).get(),
    ]);

    const driver = driverDoc.data();
    const token = driver && driver.fcm_token;
    if (!token) {
      logger.info(`Driver ${ride.driver_id} has no FCM token; skipping notification`);
      return;
    }

    const passengerName = firstNameLastInitial(passengerDoc.data());
    const body =
      `You have a new passenger (${passengerName}) for your trip to ` +
      `"${dropoffName(ride)}" on ${formatRideDate(ride)}. ` +
      "View your ride details now.";

    await admin.messaging().send({
      token,
      notification: {title: "New passenger!", body},
      // The app reads ride_id to open the right ride when the driver taps.
      data: {
        type: "ride_booked",
        ride_id: ride.ride_id,
        passenger_id: booking.userId,
      },
      android: {priority: "high"},
    });

    logger.info(`Notified driver ${ride.driver_id} of booking ${snapshot.id}`);
  } catch (error) {
    logger.error(`Failed to notify driver for booking ${snapshot.id}`, error);
  }
});

// --------------------------------------------------------- Payment holds

/**
 * The passenger is authorized — not charged — when they book. The hold becomes
 * a charge when the driver completes the ride, and is released if either party
 * cancels (Milestone 4, §1.2).
 *
 * Not yet called by the app; booking still charges immediately through
 * /v1/payment/stripeConnect/charge/destination/paymentintent.
 */
exports.payments = onRequest({secrets: [stripeSecretKey]}, async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).json({error: "Use POST"});
    return;
  }

  try {
    switch (req.path) {
      case "/hold":
        res.json(await createHold(req.body));
        return;
      case "/capture":
        res.json(await capture(req.body));
        return;
      case "/release":
        res.json(await release(req.body));
        return;
      default:
        res.status(404).json({error: `Unknown path ${req.path}`});
    }
  } catch (error) {
    logger.error("Payment request failed", error);
    res.status(400).json({error: error.message});
  }
});

/**
 * Authorizes the full amount without taking the money. `capture_method:
 * manual` is what makes this a hold rather than a charge.
 */
async function createHold(body) {
  const intent = await stripe().paymentIntents.create({
    amount: parseInt(body.amount, 10),
    currency: "usd",
    capture_method: "manual",
    confirm: true,
    customer: body.customerId || undefined,
    payment_method: body.paymentMethodId,
    receipt_email: body.email,
    transfer_group: body.transferGroup,
    application_fee_amount: parseInt(body.applicationFee, 10),
    transfer_data: {destination: body.destination},
    return_url: body.returnUrl,
    off_session: false,
  });

  return {status: intent.status, id: intent.id, clientSecret: intent.client_secret};
}

/** Settles a hold once the ride is complete. */
async function capture({paymentIntentId}) {
  const intent = await stripe().paymentIntents.capture(paymentIntentId);
  return {status: intent.status, id: intent.id};
}

/**
 * Releases a hold when a ride is canceled. An uncaptured intent is canceled
 * outright; anything already captured is refunded instead.
 */
async function release({paymentIntentId}) {
  const intent = await stripe().paymentIntents.retrieve(paymentIntentId);

  if (intent.status === "succeeded") {
    const refund = await stripe().refunds.create({
      payment_intent: paymentIntentId,
      refund_application_fee: true,
      reverse_transfer: true,
    });
    return {status: "refunded", id: refund.id};
  }

  const canceled = await stripe().paymentIntents.cancel(paymentIntentId);
  return {status: canceled.status, id: canceled.id};
}
