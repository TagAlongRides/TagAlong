const test = require("node:test");
const assert = require("node:assert");

function stub(request, exports) {
  const id = require.resolve(request);
  require.cache[id] = {id, filename: id, loaded: true, children: [], paths: [], exports};
}
stub("firebase-functions/logger", {info() {}, warn() {}, error() {}, debug() {}});
stub("firebase-admin", {firestore: () => {
  throw new Error("tests pass their own db");
}});
stub("../lib/stripe", {stripe: () => ({})});

const {parseTimeOfDay, readDeparture, departedBy, migratedFields, posterWallClock} =
  require("../lib/departure");
const {markRideComplete} = require("../jobs/rideStatus");
const {planMigration} = require("../scripts/migrateRideDepartures");

const ts = (iso) => ({toDate: () => new Date(iso)});

// The ride from the bug report: shown as leaving at noon Central on Nov 22,
// stored as midnight Central plus a display string.
const LEGACY = {departure_date_time: ts("2026-11-22T06:00:00Z"), departure_time_of_day: "12:00 PM"};
const CURRENT = {
  departure_date_time: ts("2026-11-22T18:00:00Z"),
  departure_is_instant: true,
  departure_utc_offset: -360,
  departure_time_of_day: "12:00 PM",
};

// ---------------------------------------------------------------- Parsing

test("time strings the app has written", () => {
  assert.strictEqual(parseTimeOfDay("12:00 PM"), 12 * 60);
  assert.strictEqual(parseTimeOfDay("12:30 AM"), 30);
  assert.strictEqual(parseTimeOfDay("2:30 PM"), 14 * 60 + 30);
  assert.strictEqual(parseTimeOfDay("9:05 am"), 9 * 60 + 5);
  assert.strictEqual(parseTimeOfDay("11:59 PM"), 23 * 60 + 59);
  assert.strictEqual(parseTimeOfDay("14:30"), 14 * 60 + 30);
  assert.strictEqual(parseTimeOfDay("0:15"), 15);
});

test("anything else is not a time", () => {
  for (const bad of ["", "noon", "13:00 PM", "0:30 AM", "12:60 PM", "24:00", "12", null, undefined]) {
    assert.strictEqual(parseTimeOfDay(bad), null, String(bad));
  }
});

// ------------------------------------------------------------ Both shapes

test("old shape: the poster's midnight plus the time of day", () => {
  const d = readDeparture(LEGACY);
  assert.strictEqual(d.shape, "legacy");
  assert.strictEqual(d.instant.toISOString(), "2026-11-22T18:00:00.000Z");
  assert.strictEqual(d.offset, -360);
  assert.strictEqual(d.exact, true);
});

test("old shape from a zone east of UTC", () => {
  // Midnight Nov 22 in Berlin is 23:00 Nov 21 UTC.
  const d = readDeparture({departure_date_time: ts("2026-11-21T23:00:00Z"), departure_time_of_day: "8:15 AM"});
  assert.strictEqual(d.instant.toISOString(), "2026-11-22T07:15:00.000Z");
  assert.strictEqual(d.offset, 60);
});

test("current shape is read as stored, even with the legacy string beside it", () => {
  const d = readDeparture(CURRENT);
  assert.strictEqual(d.shape, "instant");
  assert.strictEqual(d.instant.toISOString(), "2026-11-22T18:00:00.000Z");
  assert.strictEqual(d.offset, -360);
});

test("a ride posted for exactly midnight is not mistaken for an old one", () => {
  const midnight = {...CURRENT, departure_date_time: ts("2026-11-22T06:00:00Z"), departure_time_of_day: "12:00 AM"};
  assert.strictEqual(readDeparture(midnight).instant.toISOString(), "2026-11-22T06:00:00.000Z");
});

test("an unreadable old time never counts as departed before its day is out", () => {
  const ride = {...LEGACY, departure_time_of_day: "lunchtime"};
  assert.strictEqual(readDeparture(ride).exact, false);
  assert.strictEqual(departedBy(ride).toISOString(), "2026-11-23T06:00:00.000Z");
  assert.strictEqual(migratedFields(ride), null);
});

test("no departure at all", () => {
  assert.strictEqual(departedBy({}), null);
  assert.strictEqual(readDeparture({departure_date_time: "2026-11-22"}).shape, "missing");
});

test("the poster's wall clock is the same for both shapes", () => {
  assert.strictEqual(posterWallClock(LEGACY).toISOString(), "2026-11-22T12:00:00.000Z");
  assert.strictEqual(posterWallClock(CURRENT).toISOString(), "2026-11-22T12:00:00.000Z");
});

// --------------------------------------------------------- markRideComplete

function fakeDb(rides) {
  const updates = [];
  const docs = (name, filters) => {
    const rows = name === "rides" ? Object.entries(rides) : [];
    return rows
        .filter(([, data]) => filters.every(([f, v]) => data[f] === v))
        .map(([id, data]) => ({id, data: () => data,
          ref: {update: async (patch) => void (updates.push([id, patch]), Object.assign(data, patch))}}));
  };
  const query = (name, filters) => ({
    where: (f, _op, v) => query(name, [...filters, [f, v]]),
    get: async () => {
      const found = docs(name, filters);
      return {empty: found.length === 0, docs: found};
    },
    add: async () => {},
  });
  return {collection: (name) => query(name, []), updates};
}

const scheduled = (fields) => ({ride_id: "r", status: "scheduled", ...fields});

test("markRideComplete waits for the real departure, not midnight", async () => {
  const db = fakeDb({legacy: scheduled(LEGACY), current: scheduled(CURRENT)});

  // 09:00 Central on the day of the ride: past midnight, before noon.
  const morning = await markRideComplete({db, now: new Date("2026-11-22T15:00:00Z")});
  assert.deepStrictEqual(morning, {completed: 0, waiting: 2, unreadable: 0});
  assert.deepStrictEqual(db.updates, []);

  // 12:30 Central: both have left.
  const afternoon = await markRideComplete({db, now: new Date("2026-11-22T18:30:00Z")});
  assert.deepStrictEqual(afternoon, {completed: 2, waiting: 0, unreadable: 0});
});

test("markRideComplete skips a ride with no departure and closes the rest", async () => {
  const db = fakeDb({broken: scheduled({}), current: scheduled(CURRENT)});
  const c = await markRideComplete({db, now: new Date("2026-11-23T00:00:00Z")});
  assert.deepStrictEqual(c, {completed: 1, waiting: 0, unreadable: 1});
});

// -------------------------------------------------------------- Migration

test("migration plan: converts old rides, leaves current and unreadable ones", () => {
  const plan = planMigration([
    {id: "a", data: {status: "scheduled", ...LEGACY}},
    {id: "b", data: {status: "scheduled", ...CURRENT}},
    {id: "c", data: {status: "complete", ...LEGACY, departure_time_of_day: "?"}},
    {id: "d", data: {status: "paid"}},
    {id: "e", data: {status: "paid", departure_date_time: ts("2026-11-01T05:00:00Z"),
      departure_time_of_day: "3:00 PM"}},
  ]);
  const [a, b, c, d, e] = plan;
  assert.strictEqual(a.action, "migrate");
  assert.strictEqual(a.after, "2026-11-22T18:00:00.000Z");
  assert.deepStrictEqual(a.fields, {
    departure_date_time: new Date("2026-11-22T18:00:00Z"),
    departure_is_instant: true,
    departure_utc_offset: -360,
  });
  assert.strictEqual(a.note, "");
  assert.strictEqual(b.action, "current");
  assert.strictEqual(c.action, "skip");
  assert.strictEqual(d.action, "skip");
  assert.match(e.note, /DST changeover/);
});
