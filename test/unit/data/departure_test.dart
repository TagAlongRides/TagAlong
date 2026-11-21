import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/util/ride_filters.dart';

Timestamp _ts(String iso) => Timestamp.fromDate(DateTime.parse(iso));

/// A complete `rides` document with the departure fields swapped for [departure].
Map<String, dynamic> _ride(Map<String, dynamic> departure) => {
      'created_at': Timestamp(1, 1),
      'ride_id': 'RIDE',
      'driver_id': 'DRIVER',
      'university': 'Virginia Tech',
      'status': 'scheduled',
      'pickup_location': {'address': '1 Main St', 'city': 'Richmond', 'state': 'VA', 'zip': '23220'},
      'dropoff_location': {'address': '700 Washington St SW', 'city': 'Blacksburg', 'zip': '24060'},
      'no_passengers': 2,
      'no_bags': 2,
      'price': 20,
      'to_campus': true,
      'driver_full_name': 'Jordan Park',
      'vehicle': {'created_at': Timestamp(1, 1), 'make': 'M', 'model': 'm', 'color': 'c', 'vehicle_id': 'v'},
      ...departure,
    };

// The ride from the bug report: noon Central on Nov 22, stored by an older
// app version as midnight Central plus a display string.
final _legacy = {'departure_date_time': _ts('2026-11-22T06:00:00Z'), 'departure_time_of_day': '12:00 PM'};
final _current = {
  'departure_date_time': _ts('2026-11-22T18:00:00Z'),
  'departure_is_instant': true,
  'departure_utc_offset': -360,
  'departure_time_of_day': '12:00 PM',
};

void main() {
  group('Departure.parseTimeOfDay', () {
    test('reads the strings the app has written', () {
      expect(Departure.parseTimeOfDay('12:00 PM'), 12 * 60);
      expect(Departure.parseTimeOfDay('12:30 AM'), 30);
      expect(Departure.parseTimeOfDay('2:30 PM'), 14 * 60 + 30);
      expect(Departure.parseTimeOfDay('9:05 am'), 9 * 60 + 5);
      expect(Departure.parseTimeOfDay('11:59 PM'), 23 * 60 + 59);
      expect(Departure.parseTimeOfDay('14:30'), 14 * 60 + 30);
    });

    test('rejects anything else', () {
      for (final bad in ['', 'noon', '13:00 PM', '0:30 AM', '12:60 PM', '24:00']) {
        expect(Departure.parseTimeOfDay(bad), isNull, reason: bad);
      }
    });

    test('formatting round-trips', () {
      for (var m = 0; m < 24 * 60; m += 7) {
        expect(Departure.parseTimeOfDay(Departure.formatTimeOfDay(m ~/ 60, m % 60)), m);
      }
    });
  });

  group('Departure.fromFirestore', () {
    test('old shape: poster midnight plus the time of day', () {
      final d = Departure.fromFirestore(_legacy);
      expect(d.instant.toUtc(), DateTime.utc(2026, 11, 22, 18));
      expect(d.utcOffsetMinutes, -360);
      expect(d.posterWallClock, DateTime.utc(2026, 11, 22, 12));
    });

    test('old shape from east of UTC', () {
      final d = Departure.fromFirestore(
          {'departure_date_time': _ts('2026-11-21T23:00:00Z'), 'departure_time_of_day': '8:15 AM'});
      expect(d.instant.toUtc(), DateTime.utc(2026, 11, 22, 7, 15));
      expect(d.utcOffsetMinutes, 60);
    });

    test('current shape is the stored instant', () {
      final d = Departure.fromFirestore(_current);
      expect(d.instant.toUtc(), DateTime.utc(2026, 11, 22, 18));
      expect(d.utcOffsetMinutes, -360);
    });

    test('a ride posted for midnight is not mistaken for an old one', () {
      final d = Departure.fromFirestore(
          {..._current, 'departure_date_time': _ts('2026-11-22T06:00:00Z'), 'departure_time_of_day': '12:00 AM'});
      expect(d.instant.toUtc(), DateTime.utc(2026, 11, 22, 6));
    });

    test('an unreadable old time keeps the ride on its day', () {
      final d = Departure.fromFirestore({..._legacy, 'departure_time_of_day': 'lunchtime'});
      expect(d.instant.toUtc(), DateTime.utc(2026, 11, 22, 6));
    });

    test('a missing timestamp is rejected', () {
      expect(() => Departure.fromFirestore({'departure_time_of_day': '12:00 PM'}), throwsUnsupportedError);
    });
  });

  group('RideModel', () {
    test('reads both shapes to the same departure', () {
      final legacy = RideModel.fromJson(_ride(_legacy));
      final current = RideModel.fromJson(_ride(_current));
      expect(legacy.departureDateTime, current.departureDateTime);
      expect(legacy.departureDateTime.toUtc(), DateTime.utc(2026, 11, 22, 18));
    });

    test('writes the current shape, plus the string old app versions read', () {
      final json = RideModel.fromJson(_ride(_legacy)).toJson();
      expect(json['departure_date_time'], _ts('2026-11-22T18:00:00Z'));
      expect(json['departure_is_instant'], true);
      expect(json['departure_utc_offset'], -360);
      expect(json['departure_time_of_day'], '12:00 PM');
      // Reading it back changes nothing.
      expect(RideModel.fromJson(_ride(json)).toJson()['departure_date_time'], json['departure_date_time']);
    });

    test('a ride posted from a local time keeps that time', () {
      final local = DateTime(2026, 11, 22, 14, 30);
      final json = Departure.local(local).toFirestore();
      expect((json['departure_date_time'] as Timestamp).toDate(), local);
      expect(json['departure_utc_offset'], local.timeZoneOffset.inMinutes);
      expect(json['departure_time_of_day'], '2:30 PM');
    });
  });

  group('RideFilters.matches', () {
    final ride = RideModel.fromJson(_ride(_legacy)); // leaves 18:00Z

    test('an old-shape ride stays on the board until it really leaves', () {
      // After its stored midnight but before noon Central.
      expect(const RideFilters().matches(ride, now: DateTime.utc(2026, 11, 22, 15)), isTrue);
      expect(const RideFilters().matches(ride, now: DateTime.utc(2026, 11, 22, 18, 1)), isFalse);
    });

    test('date range applies to the real departure', () {
      final now = DateTime.utc(2026, 11, 1);
      expect(RideFilters(departureDateEnd: DateTime.utc(2026, 11, 22, 17)).matches(ride, now: now), isFalse);
      expect(RideFilters(departureDateStart: DateTime.utc(2026, 11, 22, 19)).matches(ride, now: now), isFalse);
      expect(RideFilters(departureDateEnd: DateTime.utc(2026, 11, 22, 19)).matches(ride, now: now), isTrue);
    });
  });
}
