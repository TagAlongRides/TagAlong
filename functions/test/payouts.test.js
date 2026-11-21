const test = require("node:test");
const assert = require("node:assert");

function stub(request, exports) {
  const id = require.resolve(request);
  require.cache[id] = {id, filename: id, loaded: true, children: [], paths: [], exports};
}
stub("firebase-functions/logger", {info() {}, warn() {}, error() {}, debug() {}});
stub("firebase-admin", {firestore: {FieldValue: {serverTimestamp: () => "TS"}}});
stub("../lib/stripe", {stripe: () => ({})});

const {payDrivers, easternDate, FUNDS_FLOW} = require("../lib/payouts");

// ------------------------------------------------------------ Fake Firestore

function fakeDb() {
  const collections = new Map();
  let autoId = 0;
  const table = (name) => {
    if (!collections.has(name)) collections.set(name, new Map());
    return collections.get(name);
  };
  const ref = (name, id) => ({
    id,
    get: async () => {
      const data = table(name).get(id);
      return {id, exists: data !== undefined, data: () => data};
    },
    set: async (data) => void table(name).set(id, structuredClone(data)),
    update: async (patch) => {
      const data = table(name).get(id);
      if (!data) throw new Error(`no ${name}/${id}`);
      Object.assign(data, patch);
    },
  });
  const query = (name, filters) => ({
    where: (field, _op, value) => query(name, [...filters, [field, value]]),
    limit: () => query(name, filters),
    get: async () => {
      const docs = [...table(name)]
          .filter(([, data]) => filters.every(([f, v]) => data[f] === v))
          .map(([id, data]) => ({id, data: () => data, ref: ref(name, id)}));
      return {empty: docs.length === 0, size: docs.length, docs};
    },
  });
  return {
    table,
    collection: (name) => ({
      ...query(name, []),
      doc: (id) => ref(name, id || `auto_${++autoId}`),
    }),
    batch: () => {
      const ops = [];
      return {
        set: (r, data) => ops.push(() => r.set(data)),
        update: (r, patch) => ops.push(() => r.update(patch)),
        commit: async () => {
          for (const op of ops) await op();
        },
      };
    },
  };
}

// ---------------------------------------------------------------- Fake Stripe

function fakeStripe() {
  const s = {
    intents: new Map(),
    transfers: [],
    payouts: [],
    failTransfers: 0,
  };
  s.client = {
    paymentIntents: {retrieve: async (id) => s.intents.get(id)},
    transfers: {
      list: async ({transfer_group: group}) =>
        ({data: s.transfers.filter((t) => t.transfer_group === group)}),
      create: async (params) => {
        if (s.failTransfers > 0) {
          s.failTransfers--;
          throw Object.assign(new Error("Insufficient funds"), {code: "balance_insufficient"});
        }
        const transfer = {id: `tr_${s.transfers.length + 1}`, ...params};
        s.transfers.push(transfer);
        return transfer;
      },
    },
    payouts: {
      list: async (_params, {stripeAccount}) =>
        ({data: s.payouts.filter((p) => p.account === stripeAccount)}),
      create: async (params, {stripeAccount}) => {
        const payout = {id: `po_${s.payouts.length + 1}`, account: stripeAccount, ...params};
        s.payouts.push(payout);
        return payout;
      },
    },
  };
  return s;
}

// -------------------------------------------------------------------- Setup

// 10:00 Eastern on Nov 21.
const NOW = new Date("2026-11-21T15:00:00Z");
// 23:00 Eastern on Nov 20 - already Nov 21 in UTC, so a UTC day boundary
// would wrongly hold this back.
const YESTERDAY = new Date("2026-11-21T04:00:00Z");
// 01:30 Eastern on Nov 21: today, so not yet due.
const EARLY_TODAY = new Date("2026-11-21T06:30:00Z");

let db;
let stripe;

function reset() {
  db = fakeDb();
  stripe = fakeStripe();
}

function ride(id, {account = "acct_a", departs = YESTERDAY, status = "complete"} = {}) {
  db.table("rides").set(`doc_${id}`, {
    ride_id: id, status, price: 20, stripe_account_id: account,
    departure_date_time: {toDate: () => departs},
  });
}

let nextBooking = 0;
function booking(rideId, {share = 2000, account = "acct_a", legacy = false, ...fields} = {}) {
  const id = `booking_${++nextBooking}`;
  const pi = `pi_${id}`;
  stripe.intents.set(pi, legacy ?
    {id: pi, status: "succeeded", amount: share + 500, application_fee_amount: 500,
      transfer_data: {destination: account}, metadata: {}} :
    {id: pi, status: "succeeded", amount: share + 500,
      metadata: {funds_flow: FUNDS_FLOW, driver_account: account, driver_share_cents: String(share)}});
  db.table("rideBooking").set(id, {rideId, status: "complete", paymentIntentId: pi, ...fields});
  return id;
}

const run = () => payDrivers({db, stripe: stripe.client, now: NOW});
const bookingData = (id) => db.table("rideBooking").get(id);
const rideStatus = (id) => db.table("rides").get(`doc_${id}`).status;

// -------------------------------------------------------------------- Tests

test("Eastern dates, not UTC", () => {
  assert.strictEqual(easternDate(YESTERDAY), "2026-11-20");
  assert.strictEqual(easternDate(NOW), "2026-11-21");
});

test("one transfer and one payout per driver, covering all their rides", async () => {
  reset();
  ride("r1");
  ride("r2");
  const a = booking("r1", {share: 2000});
  const b = booking("r1", {share: 2000});
  const c = booking("r2", {share: 1500});

  const counts = await run();

  assert.strictEqual(stripe.transfers.length, 1);
  assert.strictEqual(stripe.transfers[0].amount, 5500);
  assert.strictEqual(stripe.transfers[0].destination, "acct_a");
  assert.strictEqual(stripe.payouts.length, 1);
  assert.strictEqual(stripe.payouts[0].amount, 5500);
  assert.strictEqual(stripe.payouts[0].account, "acct_a");
  for (const id of [a, b, c]) assert.strictEqual(bookingData(id).status, "paid");
  assert.strictEqual(rideStatus("r1"), "paid");
  assert.strictEqual(rideStatus("r2"), "paid");
  assert.strictEqual(counts.drivers, 1);
  assert.strictEqual(counts.cents, 5500);

  const [batch] = db.table("payoutBatches").values();
  assert.strictEqual(batch.status, "paid");
  assert.strictEqual(batch.transferId, stripe.transfers[0].id);
});

test("each driver is paid separately", async () => {
  reset();
  ride("r1", {account: "acct_a"});
  ride("r2", {account: "acct_b"});
  booking("r1", {account: "acct_a", share: 2000});
  booking("r2", {account: "acct_b", share: 1000});

  await run();

  assert.deepStrictEqual(
      stripe.payouts.map((p) => [p.account, p.amount]).sort(),
      [["acct_a", 2000], ["acct_b", 1000]]);
});

test("a ride that left today waits for tomorrow's run", async () => {
  reset();
  ride("r1", {departs: EARLY_TODAY});
  const a = booking("r1");

  const counts = await run();

  assert.strictEqual(stripe.payouts.length, 0);
  assert.strictEqual(bookingData(a).status, "complete");
  assert.strictEqual(counts.waiting, 1);
});

test("an old-shape ride is due by its real departure, not its midnight", async () => {
  reset();
  // Posted by an old app version in Central time: midnight Nov 20 Central is
  // 01:00 Eastern Nov 20 (yesterday), but the ride left at 11:30 PM Central,
  // which is 00:30 Eastern today. Not due yet.
  db.table("rides").set("doc_r1", {
    ride_id: "r1", status: "complete", price: 20, stripe_account_id: "acct_a",
    departure_date_time: {toDate: () => new Date("2026-11-20T06:00:00Z")},
    departure_time_of_day: "11:30 PM",
  });
  booking("r1");
  // Same shape, left at 10:00 AM Central yesterday. Due.
  db.table("rides").set("doc_r2", {
    ride_id: "r2", status: "complete", price: 20, stripe_account_id: "acct_a",
    departure_date_time: {toDate: () => new Date("2026-11-20T06:00:00Z")},
    departure_time_of_day: "10:00 AM",
  });
  booking("r2");

  const counts = await run();

  assert.strictEqual(counts.waiting, 1);
  assert.strictEqual(counts.bookings, 1);
  assert.strictEqual(rideStatus("r1"), "complete");
});

test("a second run the same day pays nothing twice", async () => {
  reset();
  ride("r1");
  booking("r1");

  await run();
  await run();

  assert.strictEqual(stripe.transfers.length, 1);
  assert.strictEqual(stripe.payouts.length, 1);
});

test("an open dispute withholds that fare; winning it pays it next run", async () => {
  reset();
  ride("r1");
  const ok = booking("r1", {share: 2000});
  const disputed = booking("r1", {share: 2000, disputeStatus: "open"});

  await run();

  assert.strictEqual(stripe.payouts[0].amount, 2000);
  assert.strictEqual(bookingData(ok).status, "paid");
  assert.strictEqual(bookingData(disputed).status, "complete");
  assert.strictEqual(rideStatus("r1"), "complete"); // still owes the withheld fare

  bookingData(disputed).disputeStatus = "won";
  await run();

  assert.strictEqual(stripe.payouts.length, 2);
  assert.strictEqual(stripe.payouts[1].amount, 2000);
  assert.strictEqual(rideStatus("r1"), "paid");
});

test("fares lost to disputes are never paid and the ride is closed", async () => {
  reset();
  ride("r1");
  booking("r1", {disputeStatus: "lost"});

  await run();

  assert.strictEqual(stripe.payouts.length, 0);
  assert.strictEqual(rideStatus("r1"), "paid");
});

test("a ride nobody booked is closed without a payout", async () => {
  reset();
  ride("r1");
  await run();
  assert.strictEqual(rideStatus("r1"), "paid");
  assert.strictEqual(stripe.payouts.length, 0);
});

test("an old destination-charge booking is paid out but not transferred again", async () => {
  reset();
  ride("r1");
  booking("r1", {share: 2000});
  booking("r1", {share: 1500, legacy: true});

  await run();

  // The legacy fare is already in the driver's Stripe balance.
  assert.strictEqual(stripe.transfers[0].amount, 2000);
  assert.strictEqual(stripe.payouts[0].amount, 3500);
});

test("a fare charged for a different driver account is not paid", async () => {
  reset();
  ride("r1", {account: "acct_a"});
  const wrong = booking("r1", {account: "acct_someone_else"});

  const counts = await run();

  assert.strictEqual(stripe.payouts.length, 0);
  assert.strictEqual(bookingData(wrong).status, "complete");
  assert.strictEqual(counts.skipped, 1);
});

test("a failed transfer is retried next run, and the fare is paid once", async () => {
  reset();
  ride("r1");
  const a = booking("r1");
  stripe.failTransfers = 1;

  const first = await run();
  assert.strictEqual(first.failed, 1);
  assert.strictEqual(stripe.payouts.length, 0);
  assert.strictEqual(bookingData(a).status, "complete");
  assert.ok(bookingData(a).payoutBatchId, "claimed by the pending batch");

  await run();

  assert.strictEqual(stripe.transfers.length, 1);
  assert.strictEqual(stripe.payouts.length, 1);
  assert.strictEqual(bookingData(a).status, "paid");
  assert.strictEqual(db.table("payoutBatches").size, 1);
});

test("a transfer made but never recorded is found, not repeated", async () => {
  reset();
  ride("r1");
  const a = booking("r1", {payoutBatchId: "batch_x"});
  db.table("payoutBatches").set("batch_x", {
    account: "acct_a", payoutDate: "2026-11-20", status: "pending", createdAt: NOW.getTime(),
    shares: {[a]: {cents: 2000, mode: "transfer", rideId: "r1"}},
    transferCents: 2000, payoutCents: 2000, transferId: null, payoutId: null,
  });
  stripe.transfers.push({id: "tr_earlier", transfer_group: "batch_x", amount: 2000});

  await run();

  assert.strictEqual(stripe.transfers.length, 1);
  assert.strictEqual(db.table("payoutBatches").get("batch_x").transferId, "tr_earlier");
  assert.strictEqual(stripe.payouts.length, 1);
});

test("a payout made but never recorded is found, not repeated", async () => {
  reset();
  ride("r1");
  const a = booking("r1", {payoutBatchId: "batch_y"});
  db.table("payoutBatches").set("batch_y", {
    account: "acct_a", payoutDate: "2026-11-20", status: "pending", createdAt: NOW.getTime(),
    shares: {[a]: {cents: 2000, mode: "transfer", rideId: "r1"}},
    transferCents: 2000, payoutCents: 2000, transferId: "tr_done", payoutId: null,
  });
  stripe.payouts.push({id: "po_earlier", account: "acct_a", amount: 2000,
    metadata: {payout_batch_id: "batch_y"}});

  await run();

  assert.strictEqual(stripe.payouts.length, 1);
  assert.strictEqual(db.table("payoutBatches").get("batch_y").status, "paid");
  assert.strictEqual(bookingData(a).status, "paid");
});

test("a fare disputed after batching, before transfer, drops out of the batch", async () => {
  reset();
  ride("r1");
  const ok = booking("r1", {share: 2000});
  const disputed = booking("r1", {share: 1000});
  stripe.failTransfers = 1;
  await run(); // batch made, transfer failed

  bookingData(disputed).disputeStatus = "open";
  await run();

  assert.strictEqual(stripe.transfers[0].amount, 2000);
  assert.strictEqual(stripe.payouts[0].amount, 2000);
  assert.strictEqual(bookingData(ok).status, "paid");
  assert.strictEqual(bookingData(disputed).status, "complete");
  assert.strictEqual(bookingData(disputed).payoutBatchId, null, "released for a later payout");
});

test("a dry run reports the plan and changes nothing", async () => {
  reset();
  ride("r1");
  const a = booking("r1", {share: 2000});

  const counts = await payDrivers({db, stripe: stripe.client, now: NOW, dryRun: true});

  assert.strictEqual(counts.plan.newBatches.length, 1);
  assert.strictEqual(counts.plan.newBatches[0].payoutCents, 2000);
  assert.strictEqual(stripe.transfers.length, 0);
  assert.strictEqual(stripe.payouts.length, 0);
  assert.strictEqual(db.table("payoutBatches").size, 0);
  assert.strictEqual(bookingData(a).status, "complete");
  assert.strictEqual(bookingData(a).payoutBatchId, undefined);
});

test("rideIds limits the run to those rides", async () => {
  reset();
  ride("r1");
  ride("r2");
  const mine = booking("r1", {share: 2000});
  const other = booking("r2", {share: 1500});

  await payDrivers({db, stripe: stripe.client, now: NOW, rideIds: ["r1"]});

  assert.strictEqual(stripe.payouts[0].amount, 2000);
  assert.strictEqual(bookingData(mine).status, "paid");
  assert.strictEqual(bookingData(other).status, "complete");
  assert.strictEqual(rideStatus("r2"), "complete");
});
