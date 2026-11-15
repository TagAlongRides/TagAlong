const test = require("node:test");
const assert = require("node:assert");

function stub(request, exports) {
  const id = require.resolve(request);
  require.cache[id] = {id, filename: id, loaded: true, children: [], paths: [], exports};
}

const state = {rides: [], bookings: [], payouts: [], jobLog: []};

/** Enough of Firestore for the scheduled jobs: two queried collections. */
function fakeFirestore() {
  const query = (name, filters = {}) => ({
    where: (field, _op, value) => query(name, {...filters, [field]: value}),
    get: async () => {
      const rows = name === "rides" ? state.rides : state.bookings;
      const docs = rows
          .filter((row) => Object.entries(filters)
              .every(([field, value]) => row.data[field] === value))
          .map((row) => ({
            id: row.id,
            data: () => row.data,
            ref: {update: async (patch) => Object.assign(row.data, patch)},
          }));
      return {empty: docs.length === 0, size: docs.length, docs};
    },
  });

  return {
    collection: (name) => ({
      ...query(name),
      add: async (entry) => state.jobLog.push(entry),
    }),
  };
}

stub("firebase-admin", {
  firestore: Object.assign(fakeFirestore, {
    FieldValue: {serverTimestamp: () => "SERVER_TIMESTAMP"},
  }),
});
stub("../lib/stripe", {
  stripe: () => ({
    payouts: {
      create: async (params, options) => {
        state.payouts.push({params, options});
        return {id: `po_${state.payouts.length}`};
      },
    },
  }),
});

const {markRidePaid} = require("../jobs/rideStatus");

const DAY = 24 * 60 * 60 * 1000;

function setup(bookings, {daysAgo = 5} = {}) {
  state.rides = [{
    id: "ride_doc",
    data: {
      ride_id: "ride_1",
      status: "complete",
      price: 15,
      stripe_account_id: "acct_driver",
      departure_date_time: {toDate: () => new Date(Date.now() - daysAgo * DAY)},
    },
  }];
  state.bookings = bookings.map((data, i) => ({
    id: `booking_${i}`,
    data: {rideId: "ride_1", status: "complete", ...data},
  }));
  state.payouts = [];
  state.jobLog = [];
}

test("pays every fare when nothing is disputed", async () => {
  setup([{}, {}]);

  await markRidePaid();

  assert.strictEqual(state.payouts.length, 1);
  assert.strictEqual(state.payouts[0].params.amount, 2 * 15 * 100);
  assert.strictEqual(state.payouts[0].options.stripeAccount, "acct_driver");
  assert.ok(state.bookings.every((b) => b.data.status === "paid"));
  assert.strictEqual(state.rides[0].data.status, "paid");
});

test("withholds a disputed fare and still pays the rest", async () => {
  setup([{}, {disputeStatus: "open"}]);

  await markRidePaid();

  // Only the undisputed fare is paid out.
  assert.strictEqual(state.payouts.length, 1);
  assert.strictEqual(state.payouts[0].params.amount, 1 * 15 * 100);

  assert.strictEqual(state.bookings[0].data.status, "paid");
  assert.strictEqual(state.bookings[1].data.status, "complete");

  // The ride stays open so the withheld fare can still be paid if the dispute
  // is won. Closing it here would strand that money permanently.
  assert.strictEqual(state.rides[0].data.status, "complete");
});

test("pays nothing while every fare is under dispute", async () => {
  setup([{disputeStatus: "open"}, {disputeStatus: "open"}]);

  await markRidePaid();

  assert.strictEqual(state.payouts.length, 0);
  assert.strictEqual(state.rides[0].data.status, "complete");
  assert.ok(state.bookings.every((b) => b.data.status === "complete"));
});

test("closes the ride when every fare was lost to a dispute", async () => {
  setup([{disputeStatus: "lost"}, {disputeStatus: "lost"}]);

  await markRidePaid();

  // Nothing to pay, and nothing will change: lost is terminal, so the ride
  // must not be reconsidered on every subsequent run.
  assert.strictEqual(state.payouts.length, 0);
  assert.strictEqual(state.rides[0].data.status, "paid");
});

test("a fare released by a won dispute is paid on the next run", async () => {
  setup([{disputeStatus: "won"}]);

  await markRidePaid();

  assert.strictEqual(state.payouts.length, 1);
  assert.strictEqual(state.payouts[0].params.amount, 15 * 100);
  assert.strictEqual(state.rides[0].data.status, "paid");
});

test("does not pay before the cool-off period has elapsed", async () => {
  setup([{}], {daysAgo: 1});

  await markRidePaid();

  assert.strictEqual(state.payouts.length, 0);
  assert.strictEqual(state.rides[0].data.status, "complete");
});

test("reports withheld fares in the job log", async () => {
  setup([{}, {disputeStatus: "open"}]);

  await markRidePaid();

  const line = state.jobLog.map((entry) => entry.log).join(" ");
  assert.match(line, /withheld for disputes/);
});
