import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/vehicle.dart';


void main() {
  test('Vehicle should be created from Map', () {
    final map = {
      'created_at': Timestamp(1, 1),
      'make': 'Hyundai',
      'model': 'Genesis',
      'year': '2015',
      'color': 'Red',
      'vehicle_id': '9758c7ea-7a69-4b69-8181-3877b6c0b8fc'
    };
    final vehicle = Vehicle.fromJson(map);
  });

  test('Vehicle creation should fail due to null attributes', () {
    final map = {
      // 'created_at': Timestamp(1, 1),
      'make': 'Hyundai',
      'model': 'Genesis',
      'year': '2015',
      'color': 'Red',
      'vehicle_id': '9758c7ea-7a69-4b69-8181-3877b6c0b8fc'
    };
    expect(() => Vehicle.fromJson(map), throwsUnsupportedError);
  });
}