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

let client = null;

/**
 * The Stripe client, built on first use.
 *
 * Lazy because the secret is only readable once the function is running, not
 * while the module is being loaded for deployment analysis.
 */
function stripe() {
  if (!client) {
    const key = stripeSecretKey.value();
    if (!key) {
      throw new Error(
          "STRIPE_SECRET_KEY is not set. Run: firebase functions:secrets:set STRIPE_SECRET_KEY",
      );
    }
    client = new Stripe(key);
  }
  return client;
}

/**
 * Which *kind* of key is configured, never the key itself.
 *
 * Stripe settings — including the Accounts v1 policy toggle — are scoped to one
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

module.exports = {stripe, stripeSecretKey, keyMode, logPlatformIdentity};
