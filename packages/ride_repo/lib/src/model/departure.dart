import 'package:cloud_firestore/cloud_firestore.dart';

/// How a ride's departure is stored, and how to read either stored shape.
///
/// **Current shape** (written since the departure fix):
///  * `departure_date_time` — Timestamp of the real moment the ride leaves.
///    This is the one source of truth; everything reads it.
///  * `departure_is_instant: true` — says the timestamp above is the real
///    moment. Without it a reader can't tell a midnight ride from an old one.
///  * `departure_utc_offset` — the poster's UTC offset in minutes at the
///    moment of departure, so a server (which has no idea where the driver is)
///    can still print the driver's wall-clock date and time.
///  * `departure_time_of_day` — "12:00 PM" in the poster's wall clock. Derived
///    from the two fields above and written **only** so copies of the app that
///    predate this change can still parse and show the ride. Nothing new reads
///    it from a current-shape document. Stop writing it once those versions
///    are gone.
///
/// **Old shape** (older app versions, and documents not yet migrated): no
/// `departure_is_instant`; `departure_date_time` is midnight of the departure
/// day in the poster's time zone and `departure_time_of_day` holds the time.
/// Because the timestamp is the poster's own midnight, adding the time of day
/// gives the real moment without knowing their zone (it is an hour out only
/// for a ride on a daylight-saving changeover day).
class Departure {
  const Departure({required this.instant, required this.utcOffsetMinutes});

  /// When the ride leaves, as a UTC-comparable [DateTime].
  final DateTime instant;

  /// The poster's UTC offset at [instant], in minutes (Central = -360).
  final int utcOffsetMinutes;

  /// Departure read from a `rides` document of either shape.
  ///
  /// Throws [UnsupportedError] when `departure_date_time` isn't a Timestamp.
  /// An old-shape document whose time string can't be parsed keeps its
  /// midnight, so the ride still shows on the right day.
  factory Departure.fromFirestore(Map<String, dynamic> json) {
    final stamp = json['departure_date_time'];
    if (stamp is! Timestamp) {
      throw UnsupportedError('Invalid ride - departure_date_time is $stamp');
    }
    final stored = stamp.toDate();
    final legacyTime = json['departure_time_of_day'];
    final offset = json['departure_utc_offset'];

    if (json['departure_is_instant'] == true || legacyTime is! String) {
      return Departure(
        instant: stored,
        utcOffsetMinutes: offset is int ? offset : stored.timeZoneOffset.inMinutes,
      );
    }

    final minutes = parseTimeOfDay(legacyTime) ?? 0;
    return Departure(
      instant: stored.add(Duration(minutes: minutes)),
      utcOffsetMinutes: offsetFromLocalMidnight(stored),
    );
  }

  /// Departure for a ride being posted now, from the poster's local wall time.
  factory Departure.local(DateTime localDeparture) => Departure(
        instant: localDeparture,
        utcOffsetMinutes: localDeparture.timeZoneOffset.inMinutes,
      );

  /// The poster's wall-clock date and time of departure (fields read as UTC).
  DateTime get posterWallClock => instant.toUtc().add(Duration(minutes: utcOffsetMinutes));

  /// The fields to store on a `rides` document.
  Map<String, dynamic> toFirestore() {
    final wall = posterWallClock;
    return {
      'departure_date_time': Timestamp.fromDate(instant),
      'departure_is_instant': true,
      'departure_utc_offset': utcOffsetMinutes,
      'departure_time_of_day': formatTimeOfDay(wall.hour, wall.minute),
    };
  }

  /// Minutes after midnight for "12:30 PM", "9:05 am", "14:30" and the like,
  /// or null when [text] isn't a time.
  static int? parseTimeOfDay(String text) {
    final match = RegExp(r'^\s*(\d{1,2})\s*:\s*(\d{2})\s*([AaPp])?\.?\s*[Mm]?\.?\s*$')
        .firstMatch(text.replaceAll(RegExp(r'[  ]'), ' '));
    if (match == null) {
      return null;
    }
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)?.toLowerCase();
    if (minute > 59) {
      return null;
    }
    if (meridiem == null) {
      if (hour > 23) return null;
    } else {
      if (hour < 1 || hour > 12) return null;
      hour = hour % 12 + (meridiem == 'p' ? 12 : 0);
    }
    return hour * 60 + minute;
  }

  /// "12:00 PM" — the format old app versions wrote and still display.
  static String formatTimeOfDay(int hour, int minute) {
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final mm = minute.toString().padLeft(2, '0');
    return '$h12:$mm ${hour < 12 ? 'AM' : 'PM'}';
  }

  /// The UTC offset of the zone whose midnight is [midnight] (06:00Z → -360).
  static int offsetFromLocalMidnight(DateTime midnight) {
    final utc = midnight.toUtc();
    final m = utc.hour * 60 + utc.minute;
    return m <= 12 * 60 ? -m : 24 * 60 - m;
  }
}
