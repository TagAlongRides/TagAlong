import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:flutter/material.dart';


void main() {
  test('Firebase query to Ride instance', () {
    final location = {
      'city': 'Washington DC',
      'dropoff_address': 'Johnston Student Center'
    }
    final map = {
      'created_at': Timestamp(1, 1),
      'ride_id': 'SOMEID',
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'status',

      'notes': 'notes',
      'no_passengers': 2,
      'no_bags': 2,
      'price': 20,
      'vaccination_card': true,
      'to_campus': true,
      'departure_date_time': Timestamp(1, 1),
      'departure_time_of_day': "12:30 PM"
    };
    final ride = Ride.fromJson(map);
  });

  test('Firebase query to Ride instance - null `created_at`', () {
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
      'departure_time_of_day': "12:00 PM"
    };
    expect(() => Ride.fromJson(map), throwsUnsupportedError);
  });

  test('Firebase query to Ride instance - null `departure_time_of_day`', () {
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
      'departure_time_of_day': null
    };
    expect(() => Ride.fromJson(map), throwsUnsupportedError);
  });

}