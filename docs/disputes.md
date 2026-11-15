# Dispute recovery

## Why this is not automatic

TagAlong takes a passenger's money as a **destination charge**: the platform is
the merchant of record, and the driver's share is transferred to their
connected account at the moment of the charge.

When a passenger disputes a ride, Stripe debits the disputed amount *and* the
dispute fee from the **platform** balance - not the driver's. Recovering the
driver's share is not automatic. A refund can do it in one call with
`reverse_transfer: true`, which `routes/payment.js` already uses. A dispute
cannot: it needs an explicit transfer reversal.

This is a direct consequence of the Connect configuration. Express dashboard
with destination charges requires `losses_collector: "application"`, so the
platform absorbs losses - a deliberate decision - and Stripe's own
compatibility guidance is that this shape is "only viable when the platform
runs webhook-driven refund or dispute recovery workflows". There was no such
workflow, and no webhook endpoint at all.

## When the reversal happens, and why not sooner

Stripe's guidance:

> If you accept the dispute, you can reverse the transfer immediately. If you
> challenge the dispute, wait for the dispute outcome before reversing. If you
> win, don't reverse the transfer. If you lose, reverse the transfer.

So the reversal happens on `charge.dispute.closed` with `status: "lost"`, not
on `charge.dispute.created`. Reversing early and then winning means
transferring the money back, which can fail outright if the platform balance
is short.

## What the manual payout schedule buys us

Driver funds sit in the driver's Stripe balance until `markRidePaid` releases
them to their bank, because connected accounts are created with a manual
payout schedule.

That window is what makes recovery clean. A transfer reversal pulls from the
driver's Stripe **balance**; if the payout has already reached their bank, the
reversal just drives that balance negative and recovery then depends on
`debit_negative_balances`. So an open dispute withholds the fare, keeping the
money exactly where a reversal can reach it.

Concretely:

| Event | Effect |
| --- | --- |
| `charge.dispute.created` | Booking flagged `disputeStatus: "open"`. `markRidePaid` withholds that fare. Nothing is reversed. |
| `charge.dispute.closed`, won | Flag cleared. The next `markRidePaid` run pays the driver as normal. |
| `charge.dispute.closed`, lost | The charge's transfer is reversed; the booking records the reversal id. |
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
  submitting evidence. Stripe's Express dashboard does not let connected
  accounts manage disputes for destination charges, so that would be the
  platform's job too.
- **Telling anyone.** A driver whose fare is withheld, or clawed back, learns
  nothing. `onRideBooked` already shows how to push a notification.
- **The dispute fee.** Stripe charges the platform a fee per dispute on top of
  the amount. It is not recovered from the driver and arguably should not be.
