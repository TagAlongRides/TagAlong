import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:tagalong/util/log.dart' as logger;

/// Supplies the vehicle make and model options for driver registration.
///
/// Prefers the carmakemodeldb API and falls back to a dataset bundled with the
/// app. The fallback exists because the API answers an expired subscription
/// with `HTTP 200` and a plain string body rather than an error status:
///
///     "You need an active subscription to access this data."
///
/// The previous implementation checked only the status code and then cast the
/// decoded body straight to `List`, so a lapsed subscription surfaced as an
/// unhandled type error, an empty dropdown, and a driver registration page
/// nobody could complete or leave.
class CarMakeModelService {
  // TODO: The REST API token should be encrypted or hidden?
  final String _apiToken = 'bE6g4vzFSz57rjH8D4ipn8cTKL6o6HOnV8VeowYo37xyFoQgeAfIMpsrS8EI';

  static const String _assetPath = 'assets/vehicles.json';

  /// Bundled make -> models, loaded once.
  static Map<String, List<String>>? _bundled;

  /// Whether the last API call fell back to bundled data. Lets the UI say so.
  bool usedFallback = false;

  Future<Map<String, List<String>>> _loadBundled() async {
    if (_bundled != null) return _bundled!;
    try {
      final raw = json.decode(await rootBundle.loadString(_assetPath)) as Map<String, dynamic>;
      final makes = raw['makes'] as Map<String, dynamic>;
      _bundled = makes.map((make, models) => MapEntry(make, List<String>.from(models as List)));
    } catch (error) {
      logger.log.warning('Could not load bundled vehicle data: $error');
      _bundled = <String, List<String>>{};
    }
    return _bundled!;
  }

  /// Calls [url] and returns the decoded list, or null if the response was not
  /// a list — which is how this API reports an expired subscription.
  Future<List<dynamic>?> _getList(Uri url, String what) async {
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        logger.log.warning('Vehicle API $what returned HTTP ${response.statusCode}');
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        // e.g. "You need an active subscription to access this data."
        logger.log.warning('Vehicle API $what did not return a list: $decoded');
        return null;
      }
      return decoded;
    } catch (error) {
      logger.log.warning('Vehicle API $what failed: $error');
      return null;
    }
  }

  /// Exposes a List<String> of `Make` values.
  Future<List<String>> getMakes() async {
    final makes = await _getList(
      Uri.parse('https://carmakemodeldb.com/api/v1/car-lists/get/all/makes?api_token=$_apiToken'),
      'makes',
    );

    if (makes != null) {
      usedFallback = false;
      return makes.map((make) => make['make'] as String).toList();
    }

    usedFallback = true;
    final bundled = await _loadBundled();
    return bundled.keys.toList()..sort();
  }

  /// Exposes a List<String> of `Model` values for [make].
  Future<List<String>> getModels({required String make}) async {
    final models = await _getList(
      Uri.parse('https://carmakemodeldb.com/api/v1/car-lists/get/all/models/$make?api_token=$_apiToken'),
      'models for $make',
    );

    if (models != null) {
      usedFallback = false;
      return models.map((model) => model['model'] as String).toList();
    }

    usedFallback = true;
    final bundled = await _loadBundled();
    // A make we don't carry still has to offer something, or the driver is
    // stuck on a form they cannot complete.
    return bundled[make] ?? const ['Other'];
  }

  /// Exposes a List<String> of `year` values.
  ///
  /// The Vehicle model does not currently store a year and the dropdown is
  /// commented out of the registration form, so this is unused; it falls back
  /// to a plain range rather than a per-model one.
  Future<List<String>> getYears({required String make, required String model}) async {
    final years = await _getList(
      Uri.parse('https://carmakemodeldb.com/api/v1/car-lists/get/year-range/$make/$model?api_token=$_apiToken'),
      'years for $make $model',
    );

    if (years != null) {
      usedFallback = false;
      return years.map((year) => year['year'] as String).toList();
    }

    usedFallback = true;
    final currentYear = DateTime.now().year;
    return [for (var y = currentYear + 1; y >= 1995; y--) y.toString()];
  }
}
