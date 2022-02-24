import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/data/models/vehicle.dart';


void main() {
  test('Driver should be created from Map', () {
    final vehicle_map = {
      'created_at': Timestamp(1, 1),
      'make': 'Hyundai',
      'model': 'Genesis',
      'year': '2015',
      'color': 'Red',
      'vehicle_id': '9758c7ea-7a69-4b69-8181-3877b6c0b8fc'
    };
    final vehicle = Vehicle.fromJson(vehicle_map);

    final driver_map = {
      'created_at': Timestamp(1,1),
      'vehicle': vehicle.toJson(),
      'is_active': true
    };
    final driver = Driver.fromJson(driver_map);
  });

  test('Driver creation should fail due to null attributes', () {
    final vehicle_map = {
      'created_at': Timestamp(1, 1),
      'make': 'Hyundai',
      'model': 'Genesis',
      'year': '2015',
      'color': 'Red',
      'vehicle_id': '9758c7ea-7a69-4b69-8181-3877b6c0b8fc'
    };

    final vehicle = Vehicle.fromJson(vehicle_map);

    final driver_map = {
      // 'created_at': Timestamp(1,1),
      'vehicle': vehicle.toJson(),
      'is_active': true
    };

    expect(() => Driver.fromJson(driver_map), throwsUnsupportedError);
  });
}