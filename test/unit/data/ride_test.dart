import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/ride.dart';


void main() {
  test('Ride should be created from Map', () {
    // All "Date" like attributes should come down from
    // Firebase as [Timestamp]
    final map = {
      'created_at': Timestamp(1, 1),
      'ride_id': 'SOMEID',
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'status',
      'pickup_location': 'pickupLocation',
      'dropoff_location': 'dropoffLocation',
      'location_city': 'locationCity',
      'location_zip': 'locationZip',
      'notes': 'notes',
      'no_passengers': 2,
      'no_bags': 2,
      'price': 20,
      'vaccination_card': true,
      'to_campus': true,
      'departure_date_time': Timestamp(1, 1),
      'departure_time_of_day': Timestamp(1, 1)
    };
    final ride = Ride.fromJson(map);
  });

  test('Ride creation should fail due to null `created_at`', () {
    // All "Date" like attributes should come down from
    // Firebase as [Timestamp]
    final map = {
      'created_at': null,
      'ride_id': 'SOMEID',
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'status',
      'pickup_location': 'pickupLocation',
      'dropoff_location': 'dropoffLocation',
      'location_city': 'locationCity',
      'location_zip': 'locationZip',
      'notes': 'notes',
      'no_passengers': 2,
      'no_bags': 2,
      'price': 20,
      'vaccination_card': true,
      'to_campus': true,
      'departure_date_time': Timestamp(1, 1),
      'departure_time_of_day': Timestamp(1, 1)
    };
    expect(() => Ride.fromJson(map), throwsUnsupportedError);
  });

}