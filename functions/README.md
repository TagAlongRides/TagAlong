# TagAlong Cloud Functions

Replaces the Node 16 backend that used to live outside this repository. Node 22,
`firebase-functions` v6, v2 API throughout.

| Export | Trigger | Does |
| --- | --- | --- |
| `api` | HTTPS | The payment API the app calls. **Requires a Firebase ID token.** |
| `stripeWebhook` | HTTPS | Stripe dispute events. See `docs/disputes.md`. |
| `markRideComplete` | hourly | Closes rides whose departure time has passed. |
| `markRidePaid` | daily, 06:00 Eastern | Pays each driver for rides completed before today. |
| `onRideBooked` | Firestore create | Pushes a notification to the driver (Milestone 4 §2.1). |

## How the money moves

1. **Booking** charges the passenger the full fare (driver's price + service
   fee + tax) into **TagAlong's own Stripe balance**. Nothing goes to the
   driver yet. The driver's account and share are stored on the payment
   intent's metadata (`funds_flow: platform_hold`, `driver_account`,
   `driver_share_cents`). Booking is refused if the driver's account cannot
   yet receive transfers.
2. **Cancelling** refunds the passenger in full from TagAlong's balance. A fare
   already paid out to the driver is refused with a 409 for someone to handle
   by hand.
3. **`markRidePaid`**, once a day, takes every completed, undisputed fare from
   rides that departed before today (Eastern time) and pays each driver with
   **one transfer** to their connected account and **one payout** to their
   bank. See `lib/payouts.js`.

Each driver's payment is recorded as a `payoutBatches` document before any
money moves, and every Stripe call can be found again from it. A run that
fails partway (for example on a short platform balance) leaves the batch
`pending`, and the next day's run finishes it without paying anything twice.
Fares that are disputed or cancelled before their batch transfers drop out of
it and wait for a later run.

Bookings made before this change were destination charges, whose driver share
was transferred when the passenger paid. The payout job recognises them and
pays them out without transferring a second time; refunds and lost disputes
on them still reverse that original transfer.

A `payments` function used to offer an authorize-then-capture hold. It was
never wired to the app and has been removed; the next deploy will ask to
delete it.

## Authentication

Every `/v1/payment` route requires `Authorization: Bearer <firebase-id-token>`.
The old backend had this switched off, leaving payment intents, refunds,
transfers and payouts callable by anyone who read the endpoint URL out of the
shipped app. The client attaches the token via `HttpApiClient.tokenProvider`,
set in `lib/main.dart`.

## What was dropped

The old tree carried a lot that TagAlong never used, much of it from a
stock-trading app it was forked from:

- `signalCreate` — triggered on a `signals` collection; TagAlong only uses
  `rides`, `rideBooking` and `users`
- `firebaseUserCreate` — wrote a `profile/{uid}` doc the app never reads, and
  created a **second** Stripe customer per signup that nothing used (the app
  creates its own during registration)
- `helloWorld`, the `/rideboard` router, subscriptions, products, prices,
  setup intents, generic transfers — all unreferenced by the client
- Later, `/stripeConnect/charge/separate/paymentintent` and
  `/stripeConnect/payout`. The app never called either. The payout route also
  let any signed-in user pay out any driver's balance, which would have
  bypassed the daily payout job entirely.

## Bugs fixed in the port

- Both scheduled jobs took `(req, res, context)` but a scheduled function only
  receives an event, so the closing `res.send(...)` threw on **every** run. The
  Firestore writes had already landed, so the work happened, but each hourly
  invocation was logged as a failure.
- `/stripeConnect/payout` returned an undefined `paymentIntent` variable on
  success, so it always 500'd.
- A payout failure for one driver aborted the whole `markRidePaid` batch; each
  ride is now independent and retried next run.
- 500 responses reported `success: true`.

## Deploying

Requires the Blaze plan.

Install dependencies. Run this from inside `functions/` — running
`npm install --prefix functions` from here instead creates a nested
`functions/functions/` package:

```bash
npm install
```

Store the Stripe secret. The old code hardcoded it in eleven files, so **rotate
the key first** and store the new one:

```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
```

```bash
firebase deploy --only "functions,firestore:indexes"
```

Quote the `--only` list — PowerShell splits it on the comma otherwise.

## Cutting over from the old backend

The old `cloudfunction` is deliberately left deployed. The switch is two lines
in `packages/core/lib/src/global_constant.dart`:

```dart
const baseUrl = 'https://us-central1-tagalong-1c5fb.cloudfunctions.net/api';
const apiVersion = '/v1/';
```

Rolling back means pointing those at `.../cloudfunction` and `/api/v1/` and
shipping a build. Once a real booking has gone through the new API, the old
Node 16 functions can be deleted.
