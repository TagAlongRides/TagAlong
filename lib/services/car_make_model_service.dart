import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tagalong/util/log.dart' as logger;

/// Supplies the vehicle make and model options for driver registration, from
/// a dataset bundled with the app (`assets/vehicles.json`).
///
/// This used to call the carmakemodeldb API with a token hardcoded in this
/// file. That subscription lapsed, and the API reports that as `HTTP 200`
/// with a plain string body rather than an error status:
///
///     "You need an active subscription to access this data."
///
/// which the old code cast straight to `List`, stranding drivers on a
/// registration form they could neither complete nor leave. Milestone 1
/// section 6.1.1 only calls for "a pre-existing vehicle year-make-model
/// dataset", so the data is bundled instead: no token to leak, no network
/// call on the registration path, and nothing to renew.
///
/// To extend the list, edit `assets/vehicles.json`; `vehicles_asset_test.dart`
/// pins its shape.
class CarMakeModelService {
  static const String _assetPath = 'assets/vehicles.json';

  /// Earliest model year offered. Bounded rather than open-ended so the
  /// dropdown stays usable.
  static const int _earliestYear = 1995;

  /// Parsed once and shared; the asset never changes at runtime.
  static Map<String, List<String>>? _vehicles;

  static Future<Map<String, List<String>>> _load() async {
    if (_vehicles != null) return _vehicles!;
    try {
      final raw = json.decode(await rootBundle.loadString(_assetPath)) as Map<String, dynamic>;
      final makes = raw['makes'] as Map<String, dynamic>;
      _vehicles = makes.map((make, models) => MapEntry(make, List<String>.from(models as List)));
    } catch (error, stack) {
      // Only reachable if the asset is missing or malformed, which is a build
      // problem rather than a runtime one. Return empty so the dropdowns show
      // their error state instead of throwing.
      logger.log.severe('Could not load $_assetPath: $error', error, stack);
      _vehicles = <String, List<String>>{};
    }
    return _vehicles!;
  }

  /// Exposes a List<String> of `Make` values, alphabetically.
  Future<List<String>> getMakes() async {
    final vehicles = await _load();
    return vehicles.keys.toList()..sort();
  }

  /// Exposes a List<String> of `Model` values for [make].
  ///
  /// An unrecognised make still gets an option, so a driver with an unlisted
  /// car is not stuck on a form they cannot complete.
  Future<List<String>> getModels({required String make}) async {
    final vehicles = await _load();
    final models = vehicles[make];
    if (models == null || models.isEmpty) {
      logger.log.fine('No bundled models for "$make"; offering Other');
      return const ['Other'];
    }
    return List<String>.from(models)..sort();
  }

  /// Exposes a List<String> of `year` values, newest first.
  ///
  /// The Vehicle model does not currently store a year and the dropdown is
  /// commented out of the registration form, so this is unused. Kept because
  /// the requirements ask for a year field and the view model still exposes
  /// it.
  Future<List<String>> getYears({required String make, required String model}) async {
    final nextYear = DateTime.now().year + 1;
    return [for (var year = nextYear; year >= _earliestYear; year--) year.toString()];
  }
}
