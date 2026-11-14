import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The bundled vehicle list is what driver registration falls back to when the
/// carmakemodeldb subscription is inactive. If it is malformed the fallback
/// fails silently and the registration form becomes uncompletable, so its
/// shape is worth pinning down.
void main() {
  late Map<String, dynamic> makes;

  setUpAll(() {
    final raw = File('assets/vehicles.json').readAsStringSync();
    makes = (json.decode(raw) as Map<String, dynamic>)['makes'] as Map<String, dynamic>;
  });

  test('bundled vehicle data is present and non-trivial', () {
    expect(makes, isNotEmpty);
    expect(makes.length, greaterThan(20), reason: 'should cover makes commonly on US roads');
  });

  test('every make maps to a non-empty list of model strings', () {
    for (final entry in makes.entries) {
      expect(entry.value, isA<List<dynamic>>(), reason: '${entry.key} should map to a list');
      final models = entry.value as List<dynamic>;
      expect(models, isNotEmpty, reason: '${entry.key} has no models, which would strand the form');
      for (final model in models) {
        expect(model, isA<String>(), reason: '${entry.key} has a non-string model');
        expect((model as String).trim(), isNotEmpty);
      }
    }
  });

  test('offers an "Other" make so an unlisted car can still register', () {
    expect(makes.keys, contains('Other'));
  });
}
