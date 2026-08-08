import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_repo/ride_repo.dart';

void main() {
  test('Ride should be created from a Map - Creating Ride from Firestore query',
      () {
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

    Map<String, dynamic> car_map = {
      'created_at': DateTime.now(),
      'make': 'Make',
      'model': 'model',
      'year': '2000',
      'color': 'color',
      'vehicle_id': 'vehicleId'
    };
    Vehicle car = Vehicle.fromJson(car_map);

    final map = {
      'created_at': Timestamp(1, 1),
      'ride_id': 'SOMEID',
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'scheduled',
      'pickup_location': locationA.toJson(),
      'dropoff_location': locationB.toJson(),
      'notes': 'notes',
      'no_passengers': 2,
      'no_bags': 2,
      'price': 20,
      'vaccination_card': true,
      'to_campus': true,
      'departure_date_time': Timestamp(1, 1),
      'departure_time_of_day': "12:30 PM",
      'driver_full_name': 'fullName',
      'driver_profile_picture_url':
          'https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=104151888806758&width=200&ext=1650304041&hash=AeSWscYVpfwy66I8C9M',
      'rider_ids': [],
      'vehicle': car.toJson()
    };
    final ride = RideModel.fromJson(map);
  });

  test('Ride should NOT be created from a Map - Creating Ride from bad Map',
      () {
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
      'status': 'scheduled',
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
    expect(() => RideModel.fromJson(map), throwsUnsupportedError);
  });

  test('Ride should NOT be created from a Map - Creating Ride from bad Map',
      () {
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
      'ride_id': null,
      'driver_id': 'SOMEID',
      'university': 'university',
      'status': 'scheduled',
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
    expect(() => RideModel.fromJson(map), throwsUnsupportedError);
  });
}
