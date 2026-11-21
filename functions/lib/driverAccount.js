/*
 * Creating a driver's connected account on the Accounts v2 API.
 *
 * Split out of routes/payment.js so the payload can be unit tested without
 * standing up the Functions runtime, which the route file needs for its
 * secret.
 */
const logger = require("firebase-functions/logger");
const {stripe, stripeV2} = require("./stripe");

/**
 * Stripe wants a phone number it can parse. The app stores bare 10-digit US
 * numbers, because Milestone 1 validation asks for exactly that ("your 10
 * digit phone number without spaces or hyphens").
 *
 * Returns undefined for anything unrecognised rather than passing it through,
 * so the driver fills it in during Stripe's own onboarding instead of having
 * account creation rejected outright.
 */
function toE164(phone) {
  const digits = String(phone || "").replace(/\D/g, "");
  if (digits.length === 10) return `+1${digits}`;
  if (digits.length === 11 && digits.startsWith("1")) return `+${digits}`;
  return undefined;
}

/** Strips undefined/null/empty entries; Stripe rejects explicit nulls. */
function defined(obj) {
  return Object.fromEntries(
      Object.entries(obj).filter(([, v]) => v !== undefined && v !== null && v !== ""),
  );
}


/**
 * What drivers are selling, from Stripe's point of view.
 *
 * Without this, Stripe asks the *driver* for `business_url` during onboarding,
 * which a student giving lifts does not have. Describing the product on the
 * platform's behalf satisfies that requirement and removes it from the driver
 * (verified against test mode: seven requirements instead of eight).
 */
const DRIVER_PROFILE = {
  product_description: "Providing rides to other users via the TagAlong app",
};

/**
 * The Accounts v2 payload for a driver.
 *
 * Only the `recipient` configuration, and within it only
 * `stripe_balance.stripe_transfers`. Drivers never accept card payments - the
 * platform does, and money reaches drivers as destination charges - and Stripe
 * is explicit that requesting `merchant` or `card_payments` for marketplace
 * accounts is "unnecessary and causes longer onboarding". Accounts v1 forced
 * the two capabilities to be requested together, which is what made driver
 * onboarding heavier than it needed to be.
 *
 * Asking for `stripe_transfers` auto-requests `stripe_balance.payouts`, which
 * cannot be unrequested, so it is deliberately not listed.
 *
 * `dashboard: "express"` requires both responsibilities to be `application`:
 * the platform collects fees and owns negative balances. That is a deliberate
 * decision about who absorbs disputes, not a default.
 */
function driverAccountPayload(body, {withPhone}) {
  const names = [body.first_name, body.last_name].filter(Boolean);
  return defined({
    contact_email: body.email,
    display_name: names.join(" "),
    dashboard: body.type === "full" ? "full" : "express",
    identity: {
      country: "us",
      entity_type: "individual",
      individual: defined({
        given_name: body.first_name,
        surname: body.last_name,
        email: body.email,
        phone: withPhone ? toE164(body.phone) : undefined,
      }),
    },
    configuration: {
      recipient: {
        capabilities: {stripe_balance: {stripe_transfers: {requested: true}}},
      },
    },
    defaults: {
      currency: "usd",
      profile: DRIVER_PROFILE,
      responsibilities: {fees_collector: "application", losses_collector: "application"},
    },
    include: ["configuration.recipient", "identity", "requirements"],
  });
}

/**
 * Creates a driver's connected account and puts it on a manual payout schedule.
 *
 * Two things here are not obvious.
 *
 * Accounts v2 checks that a phone number is *plausible*, not merely
 * well-formed: it rejects 555 numbers with `phone_invalid` and a message
 * claiming the format is wrong when the format was fine. The phone is optional
 * and Stripe collects it during onboarding anyway, so one unusable number must
 * not cost the driver their whole account.
 *
 * Payout scheduling is not part of Accounts v2 at all - `interval` does not
 * appear anywhere in it. Setting it through the v1 endpoint does work on a v2
 * account, and it is what lets markRidePaid hold a driver's funds until the
 * ride has cleared its cool-off period.
 */
async function createDriverAccount(body) {
  let account;
  try {
    account = await stripeV2().v2.core.accounts.create(
        driverAccountPayload(body, {withPhone: true}));
  } catch (error) {
    if (!error || error.code !== "phone_invalid") {
      throw error;
    }
    logger.info("Stripe rejected the driver's phone number; creating without it", {
      stripeParam: error.param,
    });
    account = await stripeV2().v2.core.accounts.create(
        driverAccountPayload(body, {withPhone: false}));
  }

  await stripe().accounts.update(account.id, {
    settings: {payouts: {schedule: {interval: "manual"}}},
  });

  return account;
}

module.exports = {
  createDriverAccount,
  driverAccountPayload,
  DRIVER_PROFILE,
  toE164,
  defined,
};
