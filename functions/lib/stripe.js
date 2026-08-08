const Stripe = require("stripe");
const {defineSecret} = require("firebase-functions/params");

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

module.exports = {stripe, stripeSecretKey};
