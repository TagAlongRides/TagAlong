import 'package:flutter/material.dart';
import '../services/car_make_model_service.dart';
import 'package:tagalong/util/log.dart' as logger;

class RegisterDriverViewModel extends ChangeNotifier {

  String? make;
  String? model;
  String? year;
  String? color;

  bool hasMakeUpdated = false;
  bool hasModelUpdated = false;
  bool hasYearUpdated = false;

  final CarMakeModelService _carMakeModelService = CarMakeModelService();

  /// Updates [make] and resets [model], [year], [color].
  ///
  /// This function will also notify all listeners to rebuild.
  void updateMake({required String make}) {
    this.make = make;
    this.model = null;
    this.year = null;
    this.color = null;
    this.hasMakeUpdated = true;
    // Tell listening Widgets to rebuild
    logger.log.fine('updateMake($make) - notifying listeners');
    notifyListeners();
  }

  /// Updates [model] and resets [year], [color].
  ///
  /// This function will also notify all listeners to rebuild.
  void updateModel({required String model}) {
    this.model = model;
    this.year = null;
    this.color = null;
    this.hasModelUpdated = true;
    // Tell listening Widgets to rebuild
    logger.log.fine('updateModel($model) - notifying listeners');
    notifyListeners();
  }

  /// Updates [year] and resets [color].
  ///
  /// This function will also notify all listeners to rebuild.
  void updateYear({required String year}) {
    this.year = year;
    this.color = null;
    this.hasYearUpdated = true;
    // Tell listening Widgets to rebuild
    logger.log.fine('updateYear($year) - notifying listeners');
    notifyListeners();
  }

  /// Updates [color]
  void updateColor({required String color}) {
    this.color = color;
    notifyListeners();
  }

  Future<List<String>> getMakes() async {
    return await _carMakeModelService.getMakes();
  }

  Future<List<String>> getModels() async {
    return await _carMakeModelService.getModels(make: this.make!);
  }

  Future<List<String>> getYears() async {
    return await _carMakeModelService.getYears(make: this.make!, model: this.model!);
  }
}