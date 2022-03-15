import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/data/models/vehicle.dart';
import 'package:tagalong/util/user_data.dart';


void main() {
  test('Creation of unregistered user (successfully logging in with Facebook)', () {
    final time = DateTime.now();
    final user = TagAlongUser(
      id: "RANDOMID",
      createdAt: time,
      updatedAt: time
    );
  });

  test('Creation of unregistered user from Map', () {
    final time = DateTime.now();
    Map<String, dynamic> map = {
      "id": "RANDOMID",
      "created_at": time,
      "updated_at": time,
      "sign_in_method": SignInMethod.FACEBOOK,
      "is_registered": false,
      "first_name": "",
      "last_name": "",
      "institution": "",
      "graduation_year": null,
      "phone_number": "",
      "email_address": "",
      "driver_data": null
    };
    final user = TagAlongUser.fromJson(map);
  });

  test('Creation of unregistered user from Map, but non-nullable data', () {
    final time = DateTime.now();
    Map<String, dynamic> map = {
      "id": "RANDOMID",
      "created_at": time,
      "updated_at": null,
      "sign_in_method": SignInMethod.FACEBOOK,
      "is_registered": false,
      "first_name": "",
      "last_name": "",
      "institution": "",
      "graduation_year": null,
      "phone_number": "",
      "email_address": "",
      "driver_data": null
    };
    expect(() => TagAlongUser.fromJson(map), throwsUnsupportedError);
  });

  test('Creation of unregistered user from Map with Driver data', () {
    final time = DateTime.now();
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
    Map<String, dynamic> map = {
      "id": "RANDOMID",
      "created_at": time,
      "updated_at": time,
      "sign_in_method": SignInMethod.FACEBOOK,
      "is_registered": false,
      "first_name": "",
      "last_name": "",
      "institution": "",
      "graduation_year": null,
      "phone_number": "",
      "email_address": "",
      "driver_data": driver.toJson()
    };
    final user = TagAlongUser.fromJson(map);
  });

}
