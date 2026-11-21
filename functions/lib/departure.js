/**
 * Reading a ride's departure from either stored shape.
 *
 * Current shape (app versions with the departure fix, and migrated rides):
 *   departure_date_time   Timestamp of the real moment the ride leaves
 *   departure_is_instant  true
 *   departure_utc_offset  poster's UTC offset in minutes at departure (-360)
 *   departure_time_of_day "12:00 PM", written only for old app versions
 *
 * Old shape (older app versions; documents not yet migrated): no
 * departure_is_instant, departure_date_time is midnight of the departure day
 * in the poster's zone, and departure_time_of_day holds the time. Adding the
 * time to the poster's own midnight gives the real moment without knowing the
 * zone. It is an hour out only on a daylight-saving changeover day.
 *
 * The Dart twin of this file is packages/ride_repo/lib/src/model/departure.dart.
 * Keep the two in step.
 */

const MINUTE = 60 * 1000;
const DAY = 24 * 60 * MINUTE;

/** Minutes after midnight for "12:30 PM", "9:05 am", "14:30"; null if not a time. */
function parseTimeOfDay(text) {
  if (typeof text !== "string") return null;
  const match = /^\s*(\d{1,2})\s*:\s*(\d{2})\s*([AaPp])?\.?\s*[Mm]?\.?\s*$/
      .exec(text.replace(/[  ]/g, " "));
  if (!match) return null;
  let hour = Number(match[1]);
  const minute = Number(match[2]);
  const meridiem = match[3] && match[3].toLowerCase();
  if (minute > 59) return null;
  if (!meridiem) {
    if (hour > 23) return null;
  } else {
    if (hour < 1 || hour > 12) return null;
    hour = (hour % 12) + (meridiem === "p" ? 12 : 0);
  }
  return hour * 60 + minute;
}

/** "12:00 PM" — the format old app versions wrote and still display. */
function formatTimeOfDay(minutes) {
  const hour = Math.floor(minutes / 60);
  const h12 = hour % 12 === 0 ? 12 : hour % 12;
  return `${h12}:${String(minutes % 60).padStart(2, "0")} ${hour < 12 ? "AM" : "PM"}`;
}

/** The UTC offset of the zone whose midnight is `midnight` (06:00Z -> -360). */
function offsetFromLocalMidnight(midnight) {
  const m = midnight.getUTCHours() * 60 + midnight.getUTCMinutes();
  return m <= 12 * 60 ? -m : 24 * 60 - m;
}

/** A Firestore Timestamp (or anything with toDate) as a Date, or null. */
function toDate(value) {
  return value && typeof value.toDate === "function" ? value.toDate() : null;
}

/**
 * Where a ride document stands on departure.
 *
 * Returns {shape, instant, offset, exact}:
 *   shape    "instant" | "legacy" | "missing"
 *   instant  Date the ride leaves (null when missing)
 *   offset   poster's UTC offset in minutes, or null when unknown
 *   exact    false when a legacy time string couldn't be parsed, in which
 *            case `instant` is the poster's midnight and the true moment is
 *            somewhere in the following 24 hours
 */
function readDeparture(ride) {
  const stored = toDate(ride && ride.departure_date_time);
  if (!stored) return {shape: "missing", instant: null, offset: null, exact: false};

  const offset = Number.isInteger(ride.departure_utc_offset) ? ride.departure_utc_offset : null;
  if (ride.departure_is_instant === true || typeof ride.departure_time_of_day !== "string") {
    return {shape: "instant", instant: stored, offset, exact: true};
  }

  const minutes = parseTimeOfDay(ride.departure_time_of_day);
  return {
    shape: "legacy",
    instant: minutes === null ? stored : new Date(stored.getTime() + minutes * MINUTE),
    offset: offsetFromLocalMidnight(stored),
    exact: minutes !== null,
  };
}

/**
 * The moment after which the ride has certainly left, for the jobs that close
 * and pay rides. An unreadable legacy time is taken as the end of its day, so
 * nothing is ever completed or paid early. Null when there's no departure.
 */
function departedBy(ride) {
  const d = readDeparture(ride);
  if (!d.instant) return null;
  return d.exact ? d.instant : new Date(d.instant.getTime() + DAY);
}

/**
 * The fields a migrated (current-shape) document should hold, or null when
 * the document can't be converted safely (missing departure or unparseable
 * time) or is already current.
 */
function migratedFields(ride) {
  const d = readDeparture(ride);
  if (d.shape !== "legacy" || !d.exact) return null;
  return {
    departure_date_time: d.instant,
    departure_is_instant: true,
    departure_utc_offset: d.offset,
  };
}

/** The poster's wall-clock date and time (fields read as UTC), or null. */
function posterWallClock(ride) {
  const d = readDeparture(ride);
  if (!d.instant || d.offset === null) return null;
  return new Date(d.instant.getTime() + d.offset * MINUTE);
}

module.exports = {
  parseTimeOfDay,
  formatTimeOfDay,
  offsetFromLocalMidnight,
  readDeparture,
  departedBy,
  migratedFields,
  posterWallClock,
};
