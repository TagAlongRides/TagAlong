const test = require("node:test");
const assert = require("node:assert");

const {driverAccountPayload, toE164, defined} = require("../lib/driverAccount");

const driver = {
  email: "jordan@example.edu",
  first_name: "Jordan",
  last_name: "Pierce",
  phone: "2064567890",
  type: "express",
};

test("requests the recipient configuration and nothing else", () => {
  const payload = driverAccountPayload(driver, {withPhone: true});

  // Drivers never accept card payments. Accounts v1 forced card_payments and
  // transfers to be requested together; asking for merchant capabilities here
  // would put drivers back through card-payment verification for a capability
  // they never use.
  assert.ok(payload.configuration.recipient, "recipient configuration missing");
  assert.strictEqual(payload.configuration.merchant, undefined);
  assert.strictEqual(payload.configuration.customer, undefined);
  assert.deepStrictEqual(
      payload.configuration.recipient.capabilities,
      {stripe_balance: {stripe_transfers: {requested: true}}},
  );
});

test("does not ask for stripe_balance.payouts explicitly", () => {
  const payload = driverAccountPayload(driver, {withPhone: true});

  // Requesting stripe_transfers auto-requests payouts, and payouts cannot be
  // unrequested, so listing it would be noise at best.
  const capabilities = payload.configuration.recipient.capabilities;
  assert.strictEqual(capabilities.stripe_balance.payouts, undefined);
});

test("the platform collects fees and owns losses", () => {
  const payload = driverAccountPayload(driver, {withPhone: true});

  // dashboard: "express" requires both of these to be "application". This is a
  // deliberate decision about who absorbs disputes and negative balances.
  assert.strictEqual(payload.dashboard, "express");
  assert.deepStrictEqual(payload.defaults.responsibilities, {
    fees_collector: "application",
    losses_collector: "application",
  });
});

test("describes the product so the driver is never asked for a business url", () => {
  const payload = driverAccountPayload(driver, {withPhone: true});

  assert.ok(payload.defaults.profile.product_description);
  assert.strictEqual(payload.defaults.profile.business_url, undefined);
});

test("maps the driver's details onto v2 identity fields", () => {
  const payload = driverAccountPayload(driver, {withPhone: true});

  assert.strictEqual(payload.identity.country, "us");
  assert.strictEqual(payload.identity.entity_type, "individual");
  assert.strictEqual(payload.identity.individual.given_name, "Jordan");
  assert.strictEqual(payload.identity.individual.surname, "Pierce");
  assert.strictEqual(payload.identity.individual.phone, "+12064567890");
  assert.strictEqual(payload.contact_email, "jordan@example.edu");
  assert.strictEqual(payload.display_name, "Jordan Pierce");
});

test("omits the phone entirely on the retry", () => {
  const payload = driverAccountPayload(driver, {withPhone: false});

  // Accounts v2 rejects implausible numbers outright, so the retry drops the
  // phone rather than costing the driver the whole account. Stripe collects it
  // during onboarding anyway.
  assert.strictEqual(payload.identity.individual.phone, undefined);
  assert.strictEqual(payload.identity.individual.given_name, "Jordan");
});

test("drops an unusable phone number rather than forwarding it", () => {
  const payload = driverAccountPayload({...driver, phone: "12345"}, {withPhone: true});

  assert.strictEqual(payload.identity.individual.phone, undefined);
});

test("omits optional identity fields the driver has not given", () => {
  const payload = driverAccountPayload(
      {email: "sam@example.edu", first_name: "Sam", last_name: null, phone: null},
      {withPhone: true},
  );

  assert.strictEqual(payload.identity.individual.surname, undefined);
  assert.strictEqual(payload.identity.individual.phone, undefined);
  assert.strictEqual(payload.identity.individual.given_name, "Sam");
  assert.strictEqual(payload.display_name, "Sam");
});

test("honours a full dashboard when asked for one", () => {
  const payload = driverAccountPayload({...driver, type: "full"}, {withPhone: true});

  assert.strictEqual(payload.dashboard, "full");
});

test("defaults to the express dashboard when type is absent", () => {
  const payload = driverAccountPayload({email: "a@b.edu", first_name: "A"}, {withPhone: true});

  assert.strictEqual(payload.dashboard, "express");
});

test("asks for the response fields we actually read", () => {
  const payload = driverAccountPayload(driver, {withPhone: true});

  // v2 returns null for anything not named in `include`.
  assert.ok(payload.include.includes("configuration.recipient"));
  assert.ok(payload.include.includes("requirements"));
});

test("toE164 normalises what the app stores", () => {
  // Milestone 1 asks for "your 10 digit phone number without spaces or
  // hyphens", so bare 10-digit numbers are the common case.
  assert.strictEqual(toE164("2064567890"), "+12064567890");
  assert.strictEqual(toE164("12064567890"), "+12064567890");
  assert.strictEqual(toE164("+1 (206) 456-7890"), "+12064567890");
  assert.strictEqual(toE164("12345"), undefined);
  assert.strictEqual(toE164(""), undefined);
  assert.strictEqual(toE164(null), undefined);
});

test("defined strips what Stripe rejects", () => {
  assert.deepStrictEqual(
      defined({a: 1, b: null, c: undefined, d: "", e: false, f: 0}),
      {a: 1, e: false, f: 0},
  );
});
