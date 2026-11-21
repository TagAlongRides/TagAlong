const test = require("node:test");
const assert = require("node:assert");

const {
  ForbiddenError, customerIdFor, listCards, createSetupIntent, setDefaultCard, removeCard,
} = require("../lib/paymentMethods");

/** A Firestore `users` collection holding `docs`, recording updates. */
function fakeUsers(docs) {
  const updates = [];
  return {
    updates,
    doc(id) {
      return {
        async get() {
          return {exists: id in docs, data: () => docs[id]};
        },
        async update(data) {
          updates.push([id, data]);
          Object.assign(docs[id], data);
        },
      };
    },
  };
}

/** A Stripe client with the calls these functions make, recording them. */
function fakeStripe({methods = {}, customer = {}} = {}) {
  const calls = [];
  const notFound = Object.assign(new Error("No such PaymentMethod"), {statusCode: 404});
  return {
    calls,
    customers: {
      async create(params) {
        calls.push(["customers.create", params]);
        return {id: "cus_new"};
      },
      async retrieve(id) {
        calls.push(["customers.retrieve", id]);
        return {id, ...customer};
      },
      async update(id, params) {
        calls.push(["customers.update", id, params]);
        return {id};
      },
    },
    paymentMethods: {
      async list(params) {
        calls.push(["paymentMethods.list", params]);
        return {object: "list", data: Object.values(methods), has_more: false, url: "/v1/payment_methods"};
      },
      async retrieve(id) {
        calls.push(["paymentMethods.retrieve", id]);
        if (!(id in methods)) throw notFound;
        return methods[id];
      },
      async detach(id) {
        calls.push(["paymentMethods.detach", id]);
        return {id, customer: null};
      },
    },
    setupIntents: {
      async create(params) {
        calls.push(["setupIntents.create", params]);
        return {id: "seti_1", client_secret: "seti_1_secret_x", status: "requires_payment_method"};
      },
    },
  };
}

test("the customer comes from the caller's own user record", async () => {
  const users = fakeUsers({uid_a: {stripe_customer_id: "cus_a"}});
  const stripe = fakeStripe();
  assert.strictEqual(await customerIdFor({stripe, users}, "uid_a"), "cus_a");
  assert.deepStrictEqual(stripe.calls, []);
});

test("a user without a Stripe customer gets one, saved back to their record", async () => {
  const users = fakeUsers({uid_b: {stripe_customer_id: "", first_name: "Jordan", last_name: "Rivera", email_address: "j@vt.edu"}});
  const stripe = fakeStripe();
  assert.strictEqual(await customerIdFor({stripe, users}, "uid_b"), "cus_new");
  assert.deepStrictEqual(stripe.calls[0], [
    "customers.create",
    {name: "Jordan Rivera", email: "j@vt.edu", metadata: {firebase_uid: "uid_b"}},
  ]);
  assert.deepStrictEqual(users.updates, [["uid_b", {stripe_customer_id: "cus_new"}]]);
});

test("a uid with no TagAlong account is refused", async () => {
  await assert.rejects(
    customerIdFor({stripe: fakeStripe(), users: fakeUsers({})}, "nobody"),
    ForbiddenError,
  );
});

test("the card list carries the customer's default card id", async () => {
  const stripe = fakeStripe({
    methods: {pm_1: {id: "pm_1", customer: "cus_a"}},
    customer: {invoice_settings: {default_payment_method: "pm_1"}},
  });
  const result = await listCards(stripe, "cus_a");
  assert.strictEqual(result.object, "list");
  assert.strictEqual(result.data.length, 1);
  assert.strictEqual(result.default_payment_method, "pm_1");
});

test("no default card reads as null, expanded or not", async () => {
  assert.strictEqual((await listCards(fakeStripe({customer: {invoice_settings: {}}}), "cus_a")).default_payment_method, null);
  const expanded = fakeStripe({customer: {invoice_settings: {default_payment_method: {id: "pm_9"}}}});
  assert.strictEqual((await listCards(expanded, "cus_a")).default_payment_method, "pm_9");
});

test("a setup intent saves cards to the caller's customer for later charges", async () => {
  const stripe = fakeStripe();
  const result = await createSetupIntent(stripe, "cus_a");
  assert.deepStrictEqual(result, {id: "seti_1", client_secret: "seti_1_secret_x"});
  assert.deepStrictEqual(stripe.calls[0], [
    "setupIntents.create",
    {customer: "cus_a", payment_method_types: ["card"], usage: "off_session"},
  ]);
});

test("the default can be set to the caller's own card", async () => {
  const stripe = fakeStripe({methods: {pm_1: {id: "pm_1", customer: "cus_a"}}});
  await setDefaultCard(stripe, "cus_a", "pm_1");
  assert.deepStrictEqual(stripe.calls.at(-1), [
    "customers.update", "cus_a", {invoice_settings: {default_payment_method: "pm_1"}},
  ]);
});

test("someone else's card can't be made default or removed", async () => {
  const stripe = fakeStripe({methods: {pm_x: {id: "pm_x", customer: "cus_other"}}});
  await assert.rejects(setDefaultCard(stripe, "cus_a", "pm_x"), ForbiddenError);
  await assert.rejects(removeCard(stripe, "cus_a", "pm_x"), ForbiddenError);
  assert.ok(!stripe.calls.some(([name]) => name === "customers.update" || name === "paymentMethods.detach"));
});

test("an unknown card id is refused the same way as someone else's", async () => {
  await assert.rejects(removeCard(fakeStripe(), "cus_a", "pm_missing"), ForbiddenError);
});

test("removing the caller's own card detaches it", async () => {
  const stripe = fakeStripe({methods: {pm_1: {id: "pm_1", customer: "cus_a"}}});
  assert.deepStrictEqual(await removeCard(stripe, "cus_a", "pm_1"), {id: "pm_1", detached: true});
  assert.deepStrictEqual(stripe.calls.at(-1), ["paymentMethods.detach", "pm_1"]);
});
