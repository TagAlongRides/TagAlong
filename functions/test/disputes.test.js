const test = require("node:test");
const assert = require("node:assert");

// Stub the Stripe client and firebase-admin before lib/disputes pulls them in.
// lib/stripe reads a Secret Manager value that only exists inside the
// Functions runtime, and admin is only used here for a server timestamp.
let fakeStripe;
const calls = [];

function stub(request, exports) {
  const id = require.resolve(request);
  require.cache[id] = {id, filename: id, loaded: true, children: [], paths: [], exports};
}

stub("../lib/stripe", {stripe: () => fakeStripe});
stub("firebase-admin", {
  firestore: Object.assign(() => ({}), {
    FieldValue: {serverTimestamp: () => "SERVER_TIMESTAMP"},
  }),
});

const {onDisputeCreated, onDisputeClosed, isWithheld} = require("../lib/disputes");

function resetStripe({transfer = "tr_123", reversalId = "trr_123"} = {}) {
  calls.length = 0;
  fakeStripe = {
    charges: {
      retrieve: async (id) => {
        calls.push(["charges.retrieve", id]);
        return {id, transfer};
      },
    },
    transfers: {
      createReversal: async (id, params) => {
        calls.push(["transfers.createReversal", id, params]);
        return {id: reversalId, amount: 1500};
      },
    },
  };
}

/** A Firestore stand-in holding one collection of bookings. */
function fakeDb(bookings) {
  return {
    collection: () => ({
      where: (field, _op, value) => ({
        limit: () => ({
          get: async () => {
            const match = bookings.find((b) => b.data[field] === value);
            if (!match) return {empty: true, docs: []};
            return {
              empty: false,
              docs: [{
                id: match.id,
                data: () => match.data,
                ref: {
                  update: async (patch) => Object.assign(match.data, patch),
                },
              }],
            };
          },
        }),
      }),
    }),
  };
}

const booking = () => ({
  id: "booking_1",
  data: {
    rideId: "ride_1",
    userId: "user_1",
    status: "complete",
    chargeId: "ch_123",
    paymentIntentId: "pi_123",
  },
});

test("an opened dispute withholds the fare without reversing anything", async () => {
  resetStripe();
  const rows = [booking()];
  const result = await onDisputeCreated(fakeDb(rows), {
    id: "dp_1",
    charge: "ch_123",
    payment_intent: "pi_123",
    amount: 1800,
  });

  assert.strictEqual(result.action, "withheld");
  assert.strictEqual(rows[0].data.disputeStatus, "open");
  assert.strictEqual(rows[0].data.disputeId, "dp_1");
  assert.strictEqual(rows[0].data.disputeAmount, 1800);

  // Nothing is reversed yet: Stripe's guidance is to wait for the outcome,
  // because reversing and then winning means transferring the money back.
  assert.deepStrictEqual(calls, []);
});

test("a dispute matching no booking is reported, not thrown", async () => {
  resetStripe();
  const result = await onDisputeCreated(fakeDb([]), {
    id: "dp_x",
    charge: "ch_unknown",
    amount: 500,
  });

  assert.strictEqual(result.handled, false);
  assert.match(result.reason, /no matching booking/);
});

test("a booking is found by payment intent when the charge does not match", async () => {
  resetStripe();
  const rows = [booking()];
  const result = await onDisputeCreated(fakeDb(rows), {
    id: "dp_2",
    charge: "ch_somethingelse",
    payment_intent: "pi_123",
    amount: 900,
  });

  assert.strictEqual(result.handled, true);
  assert.strictEqual(rows[0].data.disputeStatus, "open");
});

test("winning a dispute releases the withheld fare and reverses nothing", async () => {
  resetStripe();
  const rows = [booking()];
  rows[0].data.disputeStatus = "open";

  const result = await onDisputeClosed(fakeDb(rows), {
    id: "dp_1",
    charge: "ch_123",
    status: "won",
  });

  assert.strictEqual(result.action, "released");
  assert.strictEqual(rows[0].data.disputeStatus, "won");
  assert.deepStrictEqual(calls, []);
});

test("losing a dispute reverses the driver's transfer", async () => {
  resetStripe();
  const rows = [booking()];
  rows[0].data.disputeStatus = "open";

  const result = await onDisputeClosed(fakeDb(rows), {
    id: "dp_1",
    charge: "ch_123",
    status: "lost",
  });

  assert.strictEqual(result.action, "reversed");
  assert.deepStrictEqual(calls[0], ["charges.retrieve", "ch_123"]);
  assert.strictEqual(calls[1][0], "transfers.createReversal");
  assert.strictEqual(calls[1][1], "tr_123");

  // No amount: reverse whatever is left, so the driver is not holding part of
  // a fare the passenger got back.
  assert.strictEqual(calls[1][2], undefined);

  assert.strictEqual(rows[0].data.disputeStatus, "lost");
  assert.strictEqual(rows[0].data.transferReversalId, "trr_123");
});

test("an expanded transfer object is handled as well as an id", async () => {
  resetStripe({transfer: {id: "tr_expanded"}});
  const rows = [booking()];

  await onDisputeClosed(fakeDb(rows), {id: "dp_1", charge: "ch_123", status: "lost"});

  assert.strictEqual(calls[1][1], "tr_expanded");
});

test("a redelivered lost event does not reverse the transfer twice", async () => {
  resetStripe();
  const rows = [booking()];
  rows[0].data.disputeStatus = "lost";
  rows[0].data.transferReversalId = "trr_already";

  const result = await onDisputeClosed(fakeDb(rows), {
    id: "dp_1",
    charge: "ch_123",
    status: "lost",
  });

  // Stripe redelivers events. Reversing again would claw back the driver's
  // money a second time.
  assert.strictEqual(result.action, "already reversed");
  assert.deepStrictEqual(calls, []);
});

test("a lost dispute with no transfer records the loss and stops", async () => {
  resetStripe({transfer: null});
  const rows = [booking()];

  const result = await onDisputeClosed(fakeDb(rows), {
    id: "dp_1",
    charge: "ch_123",
    status: "lost",
  });

  assert.strictEqual(result.action, "no transfer");
  assert.strictEqual(rows[0].data.disputeStatus, "lost");
  assert.strictEqual(calls.length, 1); // the retrieve only
});

test("an inquiry closing is recorded without touching money", async () => {
  resetStripe();
  const rows = [booking()];

  const result = await onDisputeClosed(fakeDb(rows), {
    id: "dp_1",
    charge: "ch_123",
    status: "warning_closed",
  });

  assert.strictEqual(result.action, "recorded");
  assert.strictEqual(rows[0].data.disputeStatus, "warning_closed");
  assert.deepStrictEqual(calls, []);
});

test("isWithheld covers exactly the states where money must not move", () => {
  assert.strictEqual(isWithheld({disputeStatus: "open"}), true);
  assert.strictEqual(isWithheld({disputeStatus: "lost"}), true);
  assert.strictEqual(isWithheld({disputeStatus: "won"}), false);
  assert.strictEqual(isWithheld({disputeStatus: "warning_closed"}), false);
  assert.strictEqual(isWithheld({}), false);
  assert.strictEqual(isWithheld(undefined), false);
});
