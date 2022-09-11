import 'package:flutter/material.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/data/globals.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/util/log.dart' as logger;

import '../services/car_make_model_service.dart';

class RegisterDriverViewModel with ChangeNotifier {
  String? make;
  String? model;
  // String? year;
  String? color;

  bool hasMakeUpdated = false;
  bool hasModelUpdated = false;
  bool hasYearUpdated = false;

  final CarMakeModelService _carMakeModelService = CarMakeModelService();

  /// Updates [make] and resets [model], [color].
  ///
  /// This function will also notify all listeners to rebuild.
  void updateMake({required String make}) {
    this.make = make;
    model = null;
    // this.year = null;
    color = null;
    hasMakeUpdated = true;
    logger.log.fine('updateMake($make) - notifying listeners');
    notifyListeners();
  }

  /// Updates [model] and resets [color].
  ///
  /// This function will also notify all listeners to rebuild.
  void updateModel({required String model}) {
    this.model = model;
    // this.year = null;
    color = null;
    hasModelUpdated = true;
    // Tell listening Widgets to rebuild
    logger.log.fine('updateModel($model) - notifying listeners');
    notifyListeners();
  }

  /// Updates [year] and resets [color].
  ///
  /// This function will also notify all listeners to rebuild.
  // void updateYear({required String year}) {
  //   this.year = year;
  //   this.color = null;
  //   this.hasYearUpdated = true;
  //   // Tell listening Widgets to rebuild
  //   logger.log.fine('updateYear($year) - notifying listeners');
  //   notifyListeners();
  // }

  /// Updates [color]
  void updateColor({required String color}) {
    this.color = color;
    notifyListeners();
  }

  /// Creates a [Vehicle] instance if all instance variables are null-safe.
  ///
  /// Returns null if one attribute is null.
  Vehicle? createVehicle() {
    if (make == null || color == null || model == null) {
      logger.log.fine('createVehicle() - Some value is null!');
      return null;
    } else {
      Vehicle vehicle = Vehicle(
          createdAt: DateTime.now(),
          make: make!,
          model: model!,
          // year: year!,
          color: color!,
          vehicleId: uuid.v4());
      logger.log.fine('createVehicle() - Created vehicle: ${vehicle.toJson()}');
      return vehicle;
    }
  }

  /// Creates a [Driver] instance. Returns null if [Vehicle] creation is not possible.
  Driver? createDriver() {
    Vehicle? vehicle = createVehicle();
    if (vehicle == null) {
      logger.log.fine('createDriver() - Could not create Driver because vehicle is null');
      return null;
    } else {
      Driver driver = Driver(createdAt: DateTime.now(), vehicle: vehicle, isActive: true);
      logger.log.fine('createDriver() - Create Driver: ${driver.toString()}');
      return driver;
    }
  }

  Future<List<String>> getMakes() async {
    return await _carMakeModelService.getMakes();
  }

  Future<List<String>> getModels() async {
    return await _carMakeModelService.getModels(make: make!);
  }

  Future<List<String>> getYears() async {
    return await _carMakeModelService.getYears(make: make!, model: model!);
  }
}
