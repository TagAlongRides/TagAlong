#!/usr/bin/env node
/**
 * Moves every old-shape `rides` document to the current departure shape
 * (see lib/departure.js): departure_date_time becomes the real moment the
 * ride leaves, and departure_is_instant / departure_utc_offset are added.
 * departure_time_of_day is left as it is; old app versions still read it.
 *
 * Dry run (the default) lists every document and writes nothing:
 *
 *   node scripts/migrateRideDepartures.js --project tagalong-1c5fb
 *
 * Apply, only after the dry run has been reviewed:
 *
 *   node scripts/migrateRideDepartures.js --project tagalong-1c5fb --write
 *
 * Uses Application Default Credentials (`gcloud auth application-default
 * login`). Each update is conditional on the document not having changed
 * since it was read, so a ride edited mid-run is reported and left for a
 * rerun rather than overwritten. Rerunning is safe: migrated documents are
 * recognised and skipped.
 */

const {readDeparture, migratedFields, formatTimeOfDay} = require("../lib/departure");

/** True if `wall` (poster's wall clock, read as UTC) is a US DST changeover Sunday. */
function isUsDstChangeover(wall) {
  if (wall.getUTCDay() !== 0) return false;
  const month = wall.getUTCMonth() + 1;
  const day = wall.getUTCDate();
  return (month === 3 && day >= 8 && day <= 14) || (month === 11 && day <= 7);
}

function iso(date) {
  return date ? date.toISOString() : "-";
}

/**
 * What the migration would do with each document: [{id, action, before,
 * after, note}], `action` one of "migrate", "current", "skip".
 */
function planMigration(docs) {
  return docs.map(({id, data}) => {
    const d = readDeparture(data);
    const stored = data.departure_date_time && typeof data.departure_date_time.toDate === "function" ?
      data.departure_date_time.toDate() : null;
    const before = `${iso(stored)} + ${JSON.stringify(data.departure_time_of_day)}`;
    const base = {id, status: data.status, before};

    if (d.shape === "missing") {
      return {...base, action: "skip", after: null, note: "no departure_date_time"};
    }
    if (d.shape === "instant") {
      return {...base, action: "current", after: null, note: "already current"};
    }
    const fields = migratedFields(data);
    if (!fields) {
      return {...base, action: "skip", after: null, note: "time of day not understood"};
    }

    const wall = new Date(fields.departure_date_time.getTime() + fields.departure_utc_offset * 60000);
    const notes = [];
    const shown = formatTimeOfDay(wall.getUTCHours() * 60 + wall.getUTCMinutes());
    if (shown !== data.departure_time_of_day.trim()) notes.push(`read as ${shown}`);
    if (isUsDstChangeover(wall)) notes.push("DST changeover day: may be an hour out");
    return {
      ...base,
      action: "migrate",
      after: iso(fields.departure_date_time),
      offset: fields.departure_utc_offset,
      fields,
      note: notes.join("; "),
    };
  });
}

function printPlan(plan, out = console.log) {
  for (const p of plan) {
    out([p.action.padEnd(7), p.id, `[${p.status}]`, p.before,
      p.after ? `-> ${p.after} (UTC${p.offset >= 0 ? "+" : ""}${p.offset / 60})` : "",
      p.note ? `  ${p.note}` : ""].join("  "));
  }
  const count = (a) => plan.filter((p) => p.action === a).length;
  out(`\n${plan.length} ride(s): ${count("migrate")} to migrate, ` +
    `${count("current")} already current, ${count("skip")} skipped`);
}

async function main(argv) {
  const projectAt = argv.indexOf("--project");
  const projectId = projectAt >= 0 ? argv[projectAt + 1] : null;
  const write = argv.includes("--write");
  if (!projectId) {
    console.error("Usage: migrateRideDepartures.js --project <id> [--write]");
    process.exit(2);
  }

  const admin = require("firebase-admin");
  admin.initializeApp({projectId});
  const db = admin.firestore();

  const snapshot = await db.collection("rides").get();
  const plan = planMigration(snapshot.docs.map((doc) => ({id: doc.id, data: doc.data()})));
  console.log(`${write ? "WRITE" : "DRY RUN"} on project ${projectId}\n`);
  printPlan(plan);
  if (!write) {
    console.log("\nDry run: nothing written. Add --write to apply.");
    return;
  }

  const byId = new Map(snapshot.docs.map((doc) => [doc.id, doc]));
  let written = 0;
  let conflicts = 0;
  for (const p of plan.filter((x) => x.action === "migrate")) {
    const doc = byId.get(p.id);
    try {
      await doc.ref.update({
        ...p.fields,
        departure_date_time: admin.firestore.Timestamp.fromDate(p.fields.departure_date_time),
      }, {lastUpdateTime: doc.updateTime});
      written++;
    } catch (error) {
      conflicts++;
      console.error(`not written ${p.id}: ${error.message}`);
    }
  }
  console.log(`\n${written} written, ${conflicts} not written (rerun to pick them up)`);
}

if (require.main === module) {
  main(process.argv.slice(2)).catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = {planMigration, printPlan, isUsDstChangeover};
