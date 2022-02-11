import 'package:flutter/material.dart';
import '../services/car_make_model_service.dart';
import 'package:tagalong/util/log.dart' as logger;

class RegisterDriverViewModel extends ChangeNotifier {

  String? make;
  String? model;
  String? year;
  String? color;

  final CarMakeModelService _carMakeModelService = CarMakeModelService();

  /// Updates [make] and resets [model], [year], [color].
  ///
  /// This function will also notify all listeners to rebuild.
  void updateMake({required String make}) {
    this.make = make;
    this.model = null;
    this.year = null;
    this.color = null;

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

    // Tell listening Widgets to rebuild
    logger.log.fine('updateModel($model) - notifying listeners');
    notifyListeners();
  }

  Future<List<String>> getMakes() async {
    return await _carMakeModelService.getMakes();
  }

  Future<List<String>> getModels() async {
    return await _carMakeModelService.getModels(make: this.make!);
  }
}