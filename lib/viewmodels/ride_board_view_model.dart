import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/util/log.dart' as logger;


/// The ViewModel for the RideBoard page.
///
/// Will manage state for 3 main things:
/// 1. FAB
/// 2. Rides ListView
/// 3. Top Nav Bar
class RideBoardViewModel extends ChangeNotifier {

  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();


  // TODO: Currently checks Firebase, not best solution!!
  /// Checks whether the current user is an active driver.
  Future<bool> isActiveDriver() async {
    User? user = authService.getUser();
    if (user != null) {
      DocumentSnapshot data = await databaseService.users.doc(user.uid).get();
      Map<String, dynamic>? driverDataJson = data.get('driver_data');
      if (driverDataJson != null) {
        if (driverDataJson['is_active'] == true) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns a Future<QuerySnapshot<Map<String, dynamic>>> of ALL rides
  /// ordered by the `departure_date_time` field, from `rides` collection.
  Future<QuerySnapshot<Object?>> getAllRidesData() {
    return databaseService
        .rides
        .orderBy('departure_date_time')
        .get();
    notifyListeners();
  }


}
