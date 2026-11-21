const Stripe = require("stripe");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");

/**
 * The Stripe secret key, held in Cloud Secret Manager.
 *
 * The previous backend hardcoded this key in eleven source files. Any function
 * that talks to Stripe must declare this in its `secrets` option, or
 * `.value()` will be empty at runtime.
 */
const stripeSecretKey = defineSecret("STRIPE_SECRET_KEY");

/**
 * The signing secret for the Stripe webhook endpoint.
 *
 * Separate from the API key: it proves a request came from Stripe, and nothing
 * else. Set it with
 * `firebase functions:secrets:set STRIPE_WEBHOOK_SECRET`, taking the value
 * from the endpoint's "Signing secret" in the Stripe Dashboard.
 */
const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

/**
 * The API version every existing v1 call is pinned to.
 *
 * stripe-node sends its own pinned `Stripe-Version` header, so upgrading the
 * package from 17.7.0 to 23.x would otherwise have moved payment intents,
 * refunds, payouts and balance reads from 2025-02-24.acacia straight onto
 * 2026-10-28.endive as a side effect of the upgrade. Pinning it explicitly
 * keeps "upgrade the SDK" and "change the API version" as two separate,
 * separately testable changes.
 */
const V1_API_VERSION = "2025-02-24.acacia";

/**
 * The version the Accounts v2 API requires. stripe@23 pins this by default;
 * we ask for it per client rather than globally, so it applies only to the
 * calls that need it.
 */
const V2_API_VERSION = "2026-10-28.endive";

const clients = new Map();

function clientFor(apiVersion) {
  if (!clients.has(apiVersion)) {
    const key = stripeSecretKey.value();
    if (!key) {
      throw new Error(
          "STRIPE_SECRET_KEY is not set. Run: firebase functions:secrets:set STRIPE_SECRET_KEY",
      );
    }
    clients.set(apiVersion, new Stripe(key, {apiVersion}));
  }
  return clients.get(apiVersion);
}

/**
 * The Stripe client for v1 endpoints, built on first use.
 *
 * Lazy because the secret is only readable once the function is running, not
 * while the module is being loaded for deployment analysis.
 */
function stripe() {
  return clientFor(V1_API_VERSION);
}

/**
 * The Stripe client for the Accounts v2 endpoints (`/v2/core/...`).
 *
 * Deliberately a separate client on a separate API version, so reaching for
 * v2 is explicit at the call site and cannot drag v1 behaviour along with it.
 */
function stripeV2() {
  return clientFor(V2_API_VERSION);
}

/**
 * Which *kind* of key is configured, never the key itself.
 *
 * Stripe settings - including the Accounts v1 policy toggle - are scoped to one
 * account and one mode, and a sandbox is a separate account with its own
 * settings. So when a request is refused by policy, the first thing worth
 * knowing is which account and mode the server is authenticating as.
 */
function keyMode() {
  const match = /^(sk|rk)_(test|live)_/.exec(stripeSecretKey.value() || "");
  return match ? `${match[1]}_${match[2]}` : "unrecognised";
}

/**
 * Logs the platform account behind the configured key.
 *
 * Deliberately swallows its own failures: this only ever runs to explain
 * another error, and must never replace the error it was called to explain.
 */
async function logPlatformIdentity(context) {
  try {
    const [account, balance] = await Promise.all([
      stripe().accounts.retrieve(),
      stripe().balance.retrieve(),
    ]);
    logger.info(`Stripe platform identity (${context})`, {
      accountId: account.id,
      accountEmail: account.email,
      keyMode: keyMode(),
      livemode: balance.livemode,
      detailsSubmitted: account.details_submitted,
    });
  } catch (error) {
    logger.warn(`Could not read Stripe platform identity (${context})`, {
      detail: error && error.message,
      keyMode: keyMode(),
    });
  }
}

module.exports = {
  stripe,
  stripeV2,
  stripeSecretKey,
  stripeWebhookSecret,
  keyMode,
  logPlatformIdentity,
  V1_API_VERSION,
  V2_API_VERSION,
};
