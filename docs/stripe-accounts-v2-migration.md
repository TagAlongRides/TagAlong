# Migrating Connect to the Accounts v2 API

## Why

Stripe refuses `POST /v1/accounts` for new Connect integrations. The Dashboard
has an "Accounts v1 support" toggle that unblocks it as a compatibility
measure, and we turned it on to get driver onboarding working, but Stripe's
own guidance is explicit:

> When building a new Stripe integration, use the Accounts v2 API
> (`/v2/core/accounts`) unless you're explicitly instructed to use Accounts v1.

So v1 is an escape hatch we are currently sitting on, not a destination.

There is also a concrete product reason, beyond compliance. In Accounts v1,
`card_payments` and `transfers` **had to be requested together**. Our drivers
never accept card payments - the platform does, and money reaches drivers as
destination charges - but v1 forced us to request `card_payments` anyway, and
every requested capability adds information Stripe must verify during
onboarding. In v2 the two are independent, so we can request transfers alone
and ask drivers for materially less.

Stripe's own example for the capability we need is, verbatim, a ride-hailing
platform paying its drivers.

## What actually changes

Less than it looks. A v2 `Account` id can be passed to v1 endpoints, and the
response comes back in v1 structure.

| Area | Change |
| --- | --- |
| Account creation | **Rewrite** - `/v2/core/accounts` |
| Hosted onboarding | **Rewrite** - `/v2/core/account_links` |
| Payout schedule | **New step** - not settable in v2, see below |
| Destination charges | None - `transfer_data.destination` + `application_fee_amount` unchanged |
| Refunds, payouts, balance | None |
| Account status reads | None - keep `GET /v1/accounts/{id}`, which returns v1 shape for a v2 account |
| Flutter client | None expected, for the same reason |
| Existing v1 accounts | None - no data migration; v1 accounts keep working |

The Flutter client surviving untouched is the important one: `getAccount()`
and `charges_enabled` keep working because we keep reading status through the
v1 endpoint. Driver registration keeps sending the same request body; the
server translates it.

## Confirmed API shapes

Taken from the pinned types in `stripe@23.1.0`, not from prose.

### Creating a driver's account

```js
await stripe().v2.core.accounts.create({
  contact_email: email,
  display_name: `${firstName} ${surname}`,
  dashboard: 'express',
  identity: {
    country: 'us',
    entity_type: 'individual',
    individual: {given_name: firstName, surname, email, phone},
  },
  configuration: {
    recipient: {
      capabilities: {stripe_balance: {stripe_transfers: {requested: true}}},
    },
  },
  defaults: {
    currency: 'usd',
    responsibilities: {fees_collector: 'application', losses_collector: 'application'},
  },
  include: ['configuration.recipient', 'identity', 'requirements'],
});
```

Notes:

- `stripe_balance.payouts` is requested automatically by asking for
  `stripe_balance.stripe_transfers`, and cannot be unrequested. Do not list it.
- No `merchant` configuration. Drivers do not accept card payments.
- `dashboard: 'express'` **forces** both `fees_collector` and
  `losses_collector` to `application`, per the documented
  `account_controller_express_dash_without_application_losses_or_fees` error.
  That means TagAlong is liable for losses - see Decisions below.
- v2 returns null for properties not named in `include`.

### Hosted onboarding

```js
await stripe().v2.core.accountLinks.create({
  account: accountId,
  use_case: {
    type: 'account_onboarding',
    account_onboarding: {
      refresh_url: AppConfig.stripeConnectRefreshUrl,
      return_url: AppConfig.stripeConnectReturnUrl,
      collection_options: {fields: 'currently_due'},
    },
  },
});
```

Returns `{object, account, url, created, expires_at, livemode, use_case}`.

Two improvements worth taking while we are here:

- `collection_options.fields: 'currently_due'` collects only what is needed
  now rather than everything eventually required - directly addresses the
  onboarding flow being heavy.
- `type: 'account_update'` is a first-class flow for sending a driver back to
  fix a requirement later. v1 had no clean equivalent, and we have no handling
  for a driver whose verification goes stale.

### Payout schedule - the one real gap

TagAlong holds driver funds and releases them from `markRidePaid` after a
cool-off period, which depends on `settings.payouts.schedule.interval =
manual`. The string `interval` does not appear anywhere in the v2 Accounts
types: payout scheduling is not part of the v2 Accounts API.

Set it with the v1 endpoint immediately after creating the account:

```js
await stripe().accounts.update(accountId, {
  settings: {payouts: {schedule: {interval: 'manual'}}},
});
```

This must be verified early. If manual payouts cannot be set on a v2 account,
the payout model needs rethinking and that changes the shape of this work.

## Prerequisites

1. **Complete the Connect platform profile.** `details_submitted` is `false`
   on `acct_1U2F4RFVwQCYt59V`. The v2 create API documents
   `connect_profile_not_submitted` and `account_create_activation_required`,
   neither of which cares about API version. Likely blocks us either way.
2. **Real return and refresh URLs.** `refresh_url` is *required* in v2. We
   currently ship `https://www.returnurl.com` placeholders, and the webview
   detects completion by matching the string `returnurl`, which is accidental.
3. **Keep the v1 toggle on** until this ships, so onboarding keeps working.

## Plan

**Step 1 - Upgrade the SDK, without moving the API version.**
`stripe` 17.7.0 to 23.x. 17.7.0's `v2.core` exposes only `events` and
`eventDestinations`; `accounts` and `accountLinks` do not exist, so this is
unavoidable.

The risk is not the v2 code, it is the v1 code: stripe-node sends its own
pinned `Stripe-Version`, and 23.x pins `2026-10-28.endive`. Upgrading would
silently move every existing v1 call - payment intents, refunds, payouts -
onto a much newer API version. Mitigation: pin the client to the current
version and pass the newer version per-request only on v2 calls. Upgrade the
SDK and change the API version as two separate, separately testable things.

**Step 2 - Prove the risky parts in isolation**, before touching routes.
A scratch script against test mode: create a v2 account, set manual payouts
via v1, create a v2 account link, read it back through `GET /v1/accounts/{id}`
and confirm `charges_enabled` still parses. If any of those fail, the plan
changes and we have spent almost nothing.

**Step 3 - Rewrite the two routes** in `functions/routes/payment.js`:
`/stripeConnect/account/` and `/stripeConnect/`, keeping request and response
envelopes identical so the client is unaffected. Translate the existing
`first_name`/`last_name`/`phone` body into v2 `identity.individual`, reusing
the `toE164()` and `defined()` helpers already there.

**Step 4 - Verify the client needs nothing**, then end-to-end: register a
driver, complete onboarding, book a ride, confirm the destination charge and
the application fee, run `markRidePaid`.

**Step 5 - Turn the Accounts v1 toggle back off.** This is the step that
confirms nothing still depends on v1 creation.

## Decisions needed

- **Loss liability.** `dashboard: 'express'` forces
  `losses_collector: 'application'` - TagAlong absorbs negative balances and
  disputes. This matches what v1 Express already did, so it is not a
  regression, but it has never been stated out loud and it is a real
  financial exposure for a student ridesharing app. The alternative is a
  different dashboard type and a different onboarding experience.
- **Whether to take `account_update`** in this change or defer it. It is the
  fix for drivers whose verification lapses, which we currently cannot handle
  at all.

## Risks

- Sandboxes do not always enforce capabilities: a v2 account can take actions
  in test mode before its capabilities are `active`. Test-mode success does
  not prove live-mode correctness.
- The SDK upgrade crosses six majors. The v1 call sites need an audit
  independent of anything v2.
- Manual payouts on a v2 account is assumed, not yet proven (Step 2).
