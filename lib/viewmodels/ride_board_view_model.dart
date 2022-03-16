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

  /// The filters that will be used in [getRidesBasedOnFilters]. This is
  /// updated
  Map<String, dynamic>? filters;

  /// Data from a query to the [rides] collection
  QuerySnapshot<Object?>? querySnapshot;


  /// Updates this instance's [filters] and notifies listeners,
  /// mainly the [RideBoard] so that wh
  void updateFilters(Map<String, dynamic> filters) {
    this.filters = filters;
    notifyListeners();
  }


  // TODO: Currently checks Firebase, not best solution!!
  /// Checks whether the current user is an 1. Active 2. Driver.
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
  }

  // Future<QuerySnapshot<Object?>> getRidesBasedOnFilters({Map<String, dynamic>? filters}) async {
  Future<void> getRidesBasedOnFilters() async {
    Query rides = databaseService.rides;

    // Default Query is when `filters` is null
    if (filters == null) {
      Timestamp currentTimestamp = Timestamp.fromDate(DateTime.now());
      querySnapshot = await databaseService
          .rides
          .where('status', isEqualTo: 'Scheduled')  // Query only "open" rides
          .where('departure_date_time',
            isGreaterThan: currentTimestamp)         // Query only rides in the future
          .orderBy('departure_date_time')           // Order by when ride is leaving
          .get();
      return;
    }

    // 1. ToCampus
    if (filters != null) {
      if (filters!['to_campus'] != null) {
        Timestamp currentTimestamp = Timestamp.fromDate(DateTime.now());
        rides = rides
            .where('to_campus', isEqualTo: filters!['to_campus'])
            .where('departure_date_time',
            isGreaterThan: currentTimestamp)
            .orderBy('departure_date_time');
      }

      // 2. Departure Date
      if (filters!['departure_date_time'] != null) {
        Timestamp departTimeStamp = Timestamp.fromDate(
            filters!['departure_date_time']);
        Timestamp dayAheadDepartTimeStamp = Timestamp.fromDate(
            filters!['departure_date_time'].add(const Duration(hours: 24)));
        rides = rides.where(
            'departure_date_time', isGreaterThanOrEqualTo: departTimeStamp)
            .where('departure_date_time',
            isLessThanOrEqualTo: dayAheadDepartTimeStamp);
      }

      // Update our QuerySnapshot with the queried data
      querySnapshot = await rides.get();
      return;
    }
  }

}
