/**
 * TagAlong Cloud Functions.
 *
 * Replaces the Node 16 backend that lived outside this repository. Exports:
 *
 *  - `api`                 the payment API the app calls, now authenticated
 *  - `stripeWebhook`       Stripe dispute events
 *  - `markRideComplete`    hourly, closes rides whose departure has passed
 *  - `markRidePaid`        daily, pays each driver for rides completed before
 *                          today, out of the fares TagAlong has been holding
 *  - `onRideBooked`        pushes a notification to the driver (Milestone 4 §2.1)
 *
 * There used to be a `payments` export for authorizing a card at booking and
 * capturing it on completion. It was never wired to the app and is gone:
 * booking charges in full, and TagAlong holds the money until payout.
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onRequest} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

admin.initializeApp();

const {stripe, stripeSecretKey, stripeWebhookSecret} = require("./lib/stripe");
const {onDisputeCreated, onDisputeClosed} = require("./lib/disputes");
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

// ---------------------------------------------------------- Stripe events

/**
 * Stripe webhooks.
 *
 * Its own function rather than another route on `api`, because signature
 * verification needs the unparsed request body and `api` mounts
 * express.json() over everything.
 *
 * Only disputes are handled today. TagAlong takes passenger money as a
 * destination charge, so Stripe debits a disputed amount from the *platform*
 * balance and recovering the driver's share needs an explicit transfer
 * reversal - there is no `reverse_transfer` shortcut as there is for refunds.
 */
exports.stripeWebhook = onRequest(
    {secrets: [stripeSecretKey, stripeWebhookSecret]},
    async (req, res) => {
      const signature = req.headers["stripe-signature"];
      if (!signature) {
        res.status(400).send("Missing stripe-signature header");
        return;
      }

      let event;
      try {
        event = stripe().webhooks.constructEvent(
            req.rawBody, signature, stripeWebhookSecret.value());
      } catch (error) {
        // An unverified payload did not come from Stripe, whatever it says
        // about itself. This endpoint is public, so this matters.
        logger.warn("Rejected a webhook with an invalid signature", {
          detail: error && error.message,
        });
        res.status(400).send("Signature verification failed");
        return;
      }

      try {
        switch (event.type) {
          case "charge.dispute.created":
            await onDisputeCreated(db, event.data.object);
            break;
          case "charge.dispute.closed":
            await onDisputeClosed(db, event.data.object);
            break;
          default:
            logger.debug(`Ignoring ${event.type}`);
        }
        res.json({received: true});
      } catch (error) {
        // 500 so Stripe retries. Swallowing this would mean silently losing a
        // dispute we needed to act on, which costs real money.
        logger.error("Webhook handling failed", {
          eventType: event.type,
          eventId: event.id,
          detail: error && error.message,
        });
        res.status(500).send("Handler failed");
      }
    });

// -------------------------------------------------------------- Scheduled

exports.markRideComplete = onSchedule(
    {schedule: "0 * * * *", timeZone: "America/New_York"},
    async () => {
      await markRideComplete();
    },
);

// Once a day, early morning Eastern, so drivers are paid for yesterday's rides
// by the start of the day. markRideComplete runs hourly, so every ride that
// departed yesterday is already marked complete by then.
exports.markRidePaid = onSchedule(
    {schedule: "0 6 * * *", timeZone: "America/New_York", secrets: [stripeSecretKey]},
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
