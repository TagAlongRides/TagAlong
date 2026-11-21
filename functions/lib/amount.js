/**
 * Money amounts as they arrive from the app.
 *
 * Every amount on the wire is already in cents: the client converts with
 * `Pricing.totalInCents` / `Pricing.applicationFeeInCents`, which round with
 * `toStringAsFixed(0)` and send the result as a string, e.g. "2520".
 * Nothing here multiplies by 100 — doing that to a value that is already in
 * cents would charge the passenger a hundred times the fare.
 *
 * The point of this module is to refuse anything that is not plainly a whole
 * number of cents *before* it reaches Stripe. `parseInt(undefined)` is NaN,
 * which stripe-node form-encodes as the literal string "NaN", and Stripe
 * answers with `parameter_invalid_integer` — after a network round trip, and
 * with an error the caller cannot act on.
 */

/** Stripe's minimum charge in USD, in cents. */
const MIN_CHARGE_CENTS = 50;

/**
 * Parses a whole number of cents, or returns null.
 *
 * Accepts a safe integer or a string of digits. Rejects everything else rather
 * than guessing: a formatted string like "$12.50" or "1,250.00" means the
 * caller sent dollars for display, and a fraction like 19.99 means a
 * conversion went wrong upstream. Rounding either would charge an amount
 * nobody asked for.
 *
 * @param {unknown} value
 * @returns {number|null}
 */
function parseCents(value) {
  if (typeof value === "number") {
    return Number.isSafeInteger(value) ? value : null;
  }
  if (typeof value === "string" && /^\d+$/.test(value.trim())) {
    const cents = Number(value.trim());
    return Number.isSafeInteger(cents) ? cents : null;
  }
  return null;
}

/**
 * Why `value` cannot be charged, or null if it can.
 *
 * @param {unknown} value the raw `amount` from the request body
 * @param {string} [field] the body field name, for the message
 * @returns {string|null}
 */
function chargeAmountError(value, field = "amount") {
  const cents = parseCents(value);
  if (cents === null) {
    return `${field} must be a whole number of cents, e.g. "2520" for $25.20 (got ${describe(value)})`;
  }
  if (cents < MIN_CHARGE_CENTS) {
    return `${field} must be at least ${MIN_CHARGE_CENTS} cents (got ${cents})`;
  }
  return null;
}

/**
 * Why `value` cannot be the application fee on a charge of `amountCents`, or
 * null if it can. Zero is allowed; more than the charge itself is not.
 *
 * @param {unknown} value the raw `application_fee` from the request body
 * @param {number} amountCents the already-validated charge amount
 * @param {string} [field]
 * @returns {string|null}
 */
function applicationFeeError(value, amountCents, field = "application_fee") {
  const cents = parseCents(value);
  if (cents === null) {
    return `${field} must be a whole number of cents (got ${describe(value)})`;
  }
  if (cents > amountCents) {
    return `${field} (${cents}) cannot exceed the charge amount (${amountCents})`;
  }
  return null;
}

function describe(value) {
  if (value === undefined) return "nothing";
  try {
    return JSON.stringify(value);
  } catch (_) {
    return String(value);
  }
}

module.exports = {MIN_CHARGE_CENTS, parseCents, chargeAmountError, applicationFeeError};
