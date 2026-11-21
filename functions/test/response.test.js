const test = require("node:test");
const assert = require("node:assert");

// Keep the logger quiet and inspectable.
const logged = [];
const loggerId = require.resolve("firebase-functions/logger");
require.cache[loggerId] = {
  id: loggerId, filename: loggerId, loaded: true, children: [], paths: [],
  exports: {error: (msg, data) => logged.push([msg, data])},
};

const {serverError} = require("../lib/response");

function fakeRes() {
  return {
    statusCode: null,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    send(body) {
      this.body = body;
      return this;
    },
  };
}

test("a Stripe 400 is answered as a 400 with Stripe's message and param", () => {
  logged.length = 0;
  const res = fakeRes();
  serverError(res, {
    type: "StripeInvalidRequestError",
    statusCode: 400,
    code: "parameter_invalid_integer",
    param: "amount",
    message: "Invalid integer: NaN",
    requestId: "req_test",
  });
  assert.strictEqual(res.statusCode, 400);
  assert.strictEqual(res.body.status, 400);
  assert.strictEqual(res.body.success, false);
  assert.strictEqual(res.body.message, "Invalid integer: NaN (amount)");
  const [, data] = logged[0];
  assert.strictEqual(data.stripeCode, "parameter_invalid_integer");
  assert.strictEqual(data.stripeParam, "amount");
  assert.strictEqual(data.stripeRequestId, "req_test");
});

test("anything else is still a 500", () => {
  for (const error of [
    new Error("boom"),
    {type: "StripeAuthenticationError", statusCode: 401, message: "bad key"},
    {type: "StripeAPIError", statusCode: 500, message: "stripe down"},
  ]) {
    const res = fakeRes();
    serverError(res, error);
    assert.strictEqual(res.statusCode, 500, error.message);
  }
});
