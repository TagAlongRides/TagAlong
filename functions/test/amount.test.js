const test = require("node:test");
const assert = require("node:assert");

const {parseCents, chargeAmountError, applicationFeeError} = require("../lib/amount");

// Amounts arrive in cents (Pricing.totalInCents on the client), so the helper
// must accept a whole number of cents and refuse everything else — never round
// or rescale it into something else.

test("rejects a missing amount instead of producing NaN", () => {
  for (const value of [undefined, null, ""]) {
    assert.strictEqual(parseCents(value), null, `parseCents(${JSON.stringify(value)})`);
    assert.match(chargeAmountError(value), /whole number of cents/);
  }
});

test("rejects formatted dollar strings rather than guessing their meaning", () => {
  // parseInt("$12.50") is NaN; parseInt("1,250.00") is 1 — both wrong.
  for (const value of ["$12.50", "1,250.00"]) {
    assert.strictEqual(parseCents(value), null, value);
    assert.match(chargeAmountError(value), /whole number of cents/);
  }
});

test("rejects zero and anything under Stripe's 50-cent minimum", () => {
  assert.strictEqual(parseCents(0), 0);
  assert.match(chargeAmountError(0), /at least 50 cents/);
  assert.match(chargeAmountError(49), /at least 50 cents/);
  assert.strictEqual(chargeAmountError(50), null);
});

test("rejects fractional values, which mean a conversion went wrong upstream", () => {
  // 0.49 and 19.99 look like dollars. Treating them as cents and rounding
  // would charge 0 or 20 cents; treating them as dollars would make the
  // field's unit depend on its value. Refuse both.
  for (const value of [0.49, 19.99, "19.99"]) {
    assert.strictEqual(parseCents(value), null, String(value));
    assert.match(chargeAmountError(value), /whole number of cents/);
  }
});

test("accepts a plain integer, as a number or as the string the app sends", () => {
  assert.strictEqual(parseCents(2520), 2520);
  assert.strictEqual(parseCents("2520"), 2520);
  assert.strictEqual(parseCents(" 2520 "), 2520);
  assert.strictEqual(chargeAmountError("2520"), null);
});

test("rejects values that are not safe integers", () => {
  assert.strictEqual(parseCents(NaN), null);
  assert.strictEqual(parseCents(Infinity), null);
  assert.strictEqual(parseCents(Number.MAX_SAFE_INTEGER + 1), null);
  assert.strictEqual(parseCents("99999999999999999999"), null);
  assert.strictEqual(parseCents("-100"), null);
});

test("names the field in the message", () => {
  assert.match(chargeAmountError(undefined, "amount"), /^amount .*got nothing/);
});

test("application fee may be zero but not more than the charge", () => {
  assert.strictEqual(applicationFeeError("0", 2520), null);
  assert.strictEqual(applicationFeeError("520", 2520), null);
  assert.match(applicationFeeError("2521", 2520), /cannot exceed/);
  assert.match(applicationFeeError(undefined, 2520, "applicationFee"), /^applicationFee /);
});
