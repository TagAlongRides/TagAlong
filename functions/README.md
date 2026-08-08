# TagAlong Cloud Functions

Replaces the Node 16 backend that used to live outside this repository. Node 22,
`firebase-functions` v6, v2 API throughout.

| Export | Trigger | Does |
| --- | --- | --- |
| `api` | HTTPS | The payment API the app calls. **Requires a Firebase ID token.** |
| `markRideComplete` | hourly | Closes rides whose departure time has passed. |
| `markRidePaid` | hourly | Releases driver payouts after a 2-day cool-off. |
| `onRideBooked` | Firestore create | Pushes a notification to the driver (Milestone 4 §2.1). |
| `payments` | HTTPS | Authorize / capture / release for the payment hold. Not yet wired to the app. |

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
