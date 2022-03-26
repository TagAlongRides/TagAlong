import 'package:flutter_test/flutter_test.dart';
import 'package:tagalong/data/models/location.dart';
import 'package:tagalong/util/university_locations.dart';


void main() {
  test('Location should be created from a Map - Creating Location from Firestore query', () {
    final map = {
      'address': '1234 Example Lane',
      'city': 'SomeCity',
      'zip': '12345',
      'location_image_url': null
    };
    final location = Location.fromJson(map);
  });

  test('Location should be created from a Map with label - Creating Location from Firestore query', () {
    final map = {
      'address': '1234 Example Lane',
      'city': 'SomeCity',
      'zip': '12345',
      'label': 'SomeCity',
      'location_image_url': null
    };
    final location = Location.fromJson(map);
  });

  test('Location should NOT be created from a Map - Creating Location from a bad Map', () {
    final map = {
      'address': '1234 Example Lane',
      'city': null,
      'zip': '12345',
      'location_image_url': null
    };
    expect(() => Location.fromJson(map), throwsUnsupportedError);
  });

  test('Location should NOT be created from a Map - Creating Location from a bad Map', () {
    final map = {
      'address': null,
      'city': 'SomeCity',
      'zip': '12345',
      'location_image_url': null
    };
    expect(() => Location.fromJson(map), throwsUnsupportedError);
  });

  test('Location should NOT be created from a Map - Creating Location from a bad Map', () {
    final map = {
      'address': '1234 Example Lane',
      'city': 'SomeCity',
      'zip': null,
      'location_image_url': null
    };
    expect(() => Location.fromJson(map), throwsUnsupportedError);
  });

  test('Location creation for every "VirginiaTechLocation"', () {
    for (int i = 0; i < VirginiaTechLocation.locationNames.length; i++) {
      Location loc = VirginiaTechLocation.transformAddressIntoLocation(
        address:VirginiaTechLocation.mappings[VirginiaTechLocation.locationNames[i]]!,
        label: VirginiaTechLocation.locationNames[i]
      );
      print(loc.toString());
    }
  });

}