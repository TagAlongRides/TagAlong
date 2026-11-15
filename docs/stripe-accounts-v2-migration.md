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

## Progress

### Step 1 - done

`stripe` upgraded 17.7.0 to 23.1.0. `functions/lib/stripe.js` now holds two
clients on two explicitly pinned API versions:

- `stripe()` - `2025-02-24.acacia`, exactly what stripe@17.7.0 sent, so every
  existing v1 call behaves as before.
- `stripeV2()` - `2026-10-28.endive`, used only by `/v2/core/...` calls.

Verified: the v1 client sends acacia, the v2 client sends endive, and
`v2.core.accounts.create` exists on the v2 client.

Also confirmed from the connect-recommend skill that our intended
configuration is Stripe's documented recommended marketplace path
(`express` + `fees_collector: application` + `losses_collector: application`
with destination charges), rated CAUTION rather than blocked, and that
`configuration.recipient` with `stripe_balance.stripe_transfers` and **no**
`merchant` configuration is correct - Stripe's words: requesting
`configuration.merchant` or `card_payments` for marketplace accounts is
"unnecessary and causes longer onboarding". The preview-API-version caveat
applies only to the direct-charge path we are not using, so our path is GA.

### Carried constraint: `payment_method_types`

stripe@23 removed `payment_method_types` from `PaymentIntentCreateParams`.
`routes/payment.js` passes `payment_method_types: ["card"]` at both charge
sites (destination and separate). This still works, because the code is plain
JavaScript so the type removal is not enforced at build time, and because the
v1 client is pinned to acacia where the API still accepts the parameter.

It is left alone deliberately: changing it alters payment behaviour, which is
not part of an SDK upgrade. **Whoever moves the v1 calls off acacia must deal
with this first.**

### Outstanding CAUTION from the compatibility matrix

Express dashboard + destination charges means connected accounts cannot manage
refunds, disputes or Radar rules from their own dashboard, and Stripe debits
disputes to the *platform* first. Recovery depends on reversing the prior
transfer, and unlike refunds - where `routes/payment.js` already sets
`reverse_transfer: true` - **dispute recovery is not automatic**.

TagAlong currently has no webhook handling at all, so a disputed ride would
debit the platform with no recovery from the driver. This is a pre-existing
gap, not something the migration introduces, but the configuration is only
"viable when the platform runs webhook-driven refund or dispute recovery
workflows". Worth its own piece of work.

### Step 2 - done, all four risks retired

Ran against test mode with the key read straight from Secret Manager into the
probe process. Three throwaway accounts were created
(`acct_1UbrZP…`, `acct_1UbrZa…`, `acct_1UbraB…`); they can be ignored.

| Check | Result |
| --- | --- |
| `v2.core.accounts.create`, recipient only | OK - `applied_configurations: ["recipient"]` |
| Manual payout schedule via `v1 accounts.update` | **OK - `schedule.interval: manual`** |
| `v1 accounts.retrieve` of a v2 account | OK - returns v1 shape |
| `v2.core.accountLinks.create` | OK - `connect.stripe.com`, expires ~30 min |

The platform's `details_submitted: false` did **not** block v2 creation. No
`connect_profile_not_submitted`, no `account_create_activation_required`. The
platform profile is still worth completing, but it is not a blocker here.

A v1 read of a v2 account returns `capabilities: {"transfers":"inactive"}` -
no `card_payments` at all, which is the point of dropping the `merchant`
configuration.

### Three findings that change the plan

**1. `charges_enabled` is the wrong readiness signal now.** I previously said
the Flutter client would need no changes. That was wrong, and this is why
Step 2 existed. A v1 read of the recipient-only account returns:

```
charges_enabled  : false
payouts_enabled  : false
capabilities     : {"transfers":"inactive"}
```

`charges_enabled` describes accepting card payments. A recipient-only account
has no `merchant` configuration and cannot accept charges, so this almost
certainly stays `false` forever - and `DriverData.isStripeActive` is driven by
exactly that field in `ride_board_screen.dart` and `stripe_info_screen.dart`.
Left alone, no driver would ever read as active.

Fix: drive `isStripeActive` from `payouts_enabled`, or from the `transfers`
capability being `active`. The rewritten response model already exposes
`payoutsEnabled` and `capabilities`, so this is a small change at two call
sites. Confirm against a *completed* onboarding in Step 4 - the probe can only
show the pre-onboarding state.

**2. Accounts v2 validates that a phone number is real, not just well-formed.**
`+15551234567` is rejected with `phone_invalid` and the message "Phone number
must follow the format of '+' sign, the country code, and the subscriber
number" - which is misleading, because the format was correct. `555` numbers
are refused; `+12064567890` is accepted. v1 accepted both.

`toE164()` already emits the right shape, so real numbers are fine. But an
implausible number now fails the whole account creation. Since `phone` is
optional and the driver can supply it during onboarding, Step 3 should catch
`phone_invalid` and retry once without the phone rather than failing the
driver outright.

**3. We dropped a field that reduces driver friction.** The v2 account's
requirements, all `awaiting_action_from: user`:

```
defaults.profile.business_url
external_account
identity.attestations.terms_of_service.account   (x2)
identity.individual.date_of_birth.{day,month,year}
identity.individual.id_numbers.us_ssn_last_4
```

Date of birth, SSN last 4, a bank account and terms acceptance are all
irreducible for a US payout recipient. But `business_url` is asked of the
*driver*, and a student giving lifts has no business URL. The v1 code avoided
this by sending `business_profile.product_description` and `mcc`; the v2 call
does not set the equivalent. Step 3 should populate the v2 profile defaults so
drivers are never asked for it.

Note also no card-payment requirements appear at all, which is the onboarding
reduction this migration was meant to deliver.

### Step 3 - done

Driver account creation moved to Accounts v2.

`functions/lib/driverAccount.js` is new. The payload builder and
`createDriverAccount` live there rather than in the route file so the payload
can be unit tested without standing up the Functions runtime, which
`routes/payment.js` needs for its secret. `toE164` and `defined` moved with
them, since nothing else used them once the v1 call was gone.

- `POST /stripeConnect/account/` creates a v2 account with only the
  `recipient` configuration, then sets the manual payout schedule through the
  v1 endpoint. On `phone_invalid` it retries once without the phone.
  `type` is no longer a required body field - v1's account type is `dashboard`
  in v2 - but it is still honoured when sent.
- `POST /stripeConnect/` creates a v2 account link, with
  `collection_options: {fields: "currently_due"}` so onboarding asks for less,
  and supports `type: "account_update"` for sending a driver back to fix a
  lapsed requirement.
- Everything else is untouched: destination charges, refunds, payouts, balance
  reads, and `GET /stripeConnect/account/:id`, which still reads through the v1
  endpoint and still returns the v1 shape.

Client-side, `StripeAccount` gained `canReceivePayouts`, and both call sites
that set `DriverData.isStripeActive` now use it instead of `chargesEnabled`.
It requires *both* `payouts_enabled` and the `transfers` capability being
`active`: transfers alone means a fare cannot reach the driver's bank, payouts
alone means it can never reach their Stripe balance. Marking a driver active
early is worse than marking them active late, because a booking would then
fail part-way through taking a passenger's money.

Tests: 13 in `functions/test/driverAccount.test.js` (run with `npm test` in
`functions/`), covering the recipient-only configuration, the responsibilities,
the profile pre-fill, phone normalisation and the retry payload; plus 5 more on
the Flutter side pinning `canReceivePayouts` against the response shapes the
probe actually returned.

### Still to do

- **Step 4** - deploy, then register a driver end to end and confirm
  `canReceivePayouts` turns true on a *completed* onboarding. That is the one
  assumption the probe could not test.
- **Step 5** - turn the Accounts v1 toggle back off, which proves nothing still
  depends on v1 creation.
- **Real return and refresh URLs.** Still `https://www.returnurl.com`. v2
  requires `refresh_url`, and the web view detects completion by string
  matching `returnurl`, so onboarding appears to work while sending finished
  drivers to a domain we do not own.
- **Dispute recovery.** Unchanged by this work and still absent - see the
  CAUTION note above.
