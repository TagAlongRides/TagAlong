import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/location.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:flutter/material.dart';


void main() {
  test('Ride should be created from a Map - Creating Ride from Firestore query', () {
    var loc = {
      'address': '1234 Example Lane',
      'city': 'SomeCity',
      'zip': '12345',
      'location_image_url': null
    };
    final locationA = Location.fromJson(loc);
    loc = {
      "address": "700 Washington St SW",
      "city": "Blacksburg",
      "zip": "24060",
      "location_image_url": null
    };
    final locationB = Location.fromJson(loc);

    final map = {
      'created_at': Timestamp(1, 1),
      'ride_id': 'SOMEID',
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'status',
      'pickup_location': locationA.toJson(),
      'dropoff_location': locationB.toJson(),
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

  test('Ride should NOT be created from a Map - Creating Ride from bad Map', () {
    var loc = {
      'address': '1234 Example Lane',
      'city': 'SomeCity',
      'zip': '12345',
      'location_image_url': null
    };
    final locationA = Location.fromJson(loc);
    loc = {
      "address": "700 Washington St SW",
      "city": "Blacksburg",
      "zip": "24060",
      "location_image_url": null
    };
    final locationB = Location.fromJson(loc);

    final map = {
      'created_at': null, // Should be Timestamp
      'ride_id': 'SOMEID',
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'status',
      'pickup_location': locationA.toJson(),
      'dropoff_location': locationB.toJson(),
      'notes': 'notes',
      'no_passengers': 2,
      'no_bags': 2,
      'price': 20,
      'vaccination_card': true,
      'to_campus': true,
      'departure_date_time': Timestamp(1, 1),
      'departure_time_of_day': "12:30 PM"
    };
    expect(() => Ride.fromJson(map), throwsUnsupportedError);
  });

  test('Ride should NOT be created from a Map - Creating Ride from bad Map', () {
    var loc = {
      'address': '1234 Example Lane',
      'city': 'SomeCity',
      'zip': '12345',
      'location_image_url': null
    };
    final locationA = Location.fromJson(loc);
    loc = {
      "address": "700 Washington St SW",
      "city": "Blacksburg",
      "zip": "24060",
      "location_image_url": null
    };
    final locationB = Location.fromJson(loc);

    final map = {
      'created_at': Timestamp(1,1),
      'ride_id': null,
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'status',
      'pickup_location': locationA.toJson(),
      'dropoff_location': locationB.toJson(),
      'notes': 'notes',
      'no_passengers': 2,
      'no_bags': 2,
      'price': 20,
      'vaccination_card': true,
      'to_campus': true,
      'departure_date_time': Timestamp(1, 1),
      'departure_time_of_day': "12:30 PM"
    };
    expect(() => Ride.fromJson(map), throwsUnsupportedError);
  });
}