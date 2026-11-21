# Dispute recovery

## How money is exposed to a dispute

TagAlong charges a passenger's full fare to its **own** Stripe balance when they
book, and pays drivers once a day for rides completed before that day
(`markRidePaid`, `lib/payouts.js`). When a passenger disputes a ride, Stripe
debits the disputed amount *and* the dispute fee from TagAlong's balance.

What there is to recover depends on whether the driver has been paid yet:

- **Before payout** (the usual case, since disputes are rarely raised the same
  day). An open dispute withholds the fare from payout, so the driver never
  receives it. If the dispute is lost there is nothing to claw back.
- **After payout.** The fare went to the driver inside that day's batch
  transfer, which also covers their other rides. A lost dispute reverses only
  this fare's share of that transfer, by amount. If the driver has already
  withdrawn it to their bank, the reversal drives their Stripe balance
  negative; recovery then depends on `debit_negative_balances`, and because
  driver accounts use `losses_collector: "application"`, TagAlong absorbs
  anything that cannot be recovered.
- **Bookings from before the switch** were destination charges, transferred to
  the driver the moment the passenger paid. A lost dispute on one reverses that
  charge's transfer, as before.

## When the reversal happens, and why not sooner

Stripe's guidance:

> If you accept the dispute, you can reverse the transfer immediately. If you
> challenge the dispute, wait for the dispute outcome before reversing. If you
> win, don't reverse the transfer. If you lose, reverse the transfer.

So the reversal happens on `charge.dispute.closed` with `status: "lost"`, not
on `charge.dispute.created`. Reversing early and then winning means
transferring the money back, which can fail outright if the platform balance
is short.

| Event | Effect |
| --- | --- |
| `charge.dispute.created` | Booking flagged `disputeStatus: "open"`. `markRidePaid` withholds that fare, including dropping it from a batch that has not yet transferred. Nothing is reversed. |
| `charge.dispute.closed`, won | Flag cleared. The next `markRidePaid` run pays the driver as normal. |
| `charge.dispute.closed`, lost, not yet paid out | Recorded. Nothing to reverse; the money never left TagAlong. |
| `charge.dispute.closed`, lost, already paid out | This fare's share of the driver's batch transfer is reversed; the booking records the reversal id. |
| `charge.dispute.closed`, other | Recorded only. Inquiries debit nothing. |

A ride with a withheld fare stays `complete` rather than moving to `paid`, so
a fare released by a won dispute is still paid on a later run. Closing the
ride would strand that money permanently.

## Dispute state lives in its own fields

`RideBookingStatus` is an enum the Flutter client parses
(`active, canceled, complete, paid`). Adding a value to it would break parsing
in a deployed app, so dispute state is held in separate fields -
`disputeStatus`, `disputeId`, `disputeAmount`, `disputedAt`,
`disputeResolvedAt`, `transferReversalId` - and `status` is untouched.

## Setting it up

The webhook is its own function rather than a route on `api`, because
signature verification needs the unparsed request body and `api` mounts
`express.json()` over everything.

1. Deploy: `firebase deploy --only functions`
2. In the Stripe Dashboard, add an endpoint pointing at
   `https://us-central1-tagalong-1c5fb.cloudfunctions.net/stripeWebhook`,
   subscribed to **`charge.dispute.created`** and **`charge.dispute.closed`**.
3. Copy that endpoint's signing secret and store it:
   `firebase functions:secrets:set STRIPE_WEBHOOK_SECRET`
4. Redeploy so the function picks the secret up.

Until step 3 is done the endpoint rejects everything with a 400, which is the
correct failure: an unverified payload did not come from Stripe, whatever it
claims about itself. This endpoint is public.

Handler failures return 500 so that Stripe retries. Silently swallowing one
would mean losing a dispute we needed to act on, and Stripe redelivers events,
so the lost-dispute path refuses to reverse a transfer twice.

## Not covered

- **Responding to disputes.** This recovers money after the fact; nobody is
  submitting evidence. TagAlong is the merchant of record for every fare, so
  that would be the platform's job.
- **Telling anyone.** A driver whose fare is withheld, or clawed back, learns
  nothing. `onRideBooked` already shows how to push a notification.
- **The dispute fee.** Stripe charges the platform a fee per dispute on top of
  the amount. It is not recovered from the driver and arguably should not be.
