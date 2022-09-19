import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/util/log.dart' as logger;

/// The ViewModel for the RideBoardScreen page.
class RideBoardViewModel extends ChangeNotifier {
  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();

  /// The filters that will be used in [getRidesBasedOnFilters]. This is
  /// updated via the Modal Bottom Sheet for filtering
  Map<String, dynamic>? filters;

  /// Data from a query to the [rides] Firestore collection
  QuerySnapshot<Object?>? querySnapshot;

  /// Updates this instance's [filters] and notifies listeners,
  /// mainly for the [RideBoard] so that it will re-update with new Rides
  /// once a user clicks "Filter" button
  void updateFilters(Map<String, dynamic> filters) {
    this.filters = filters;
    notifyListeners();
  }

  /// Returns a Future<QuerySnapshot<Map<String, dynamic>>> of ALL rides
  /// ordered by the `departure_date_time` field, from `rides` collection.
  Future<QuerySnapshot<Object?>> getAllRidesData() {
    return databaseService.rides.orderBy('departure_date_time').get();
  }

  /// Asynchronously updates our current QuerySnapshot, which contains the result of the last
  /// query we had, based on the user's filters.
  Future<void> getRidesBasedOnFilters() async {
    Query rides = databaseService.rides;

    // Default Query is when `filters` is null
    if (filters == null) {
      logger.log.fine('RideBoardViewModel Querying - Filters is NULL');
      Timestamp currentTimestamp = Timestamp.fromDate(DateTime.now());
      querySnapshot = await databaseService.rides
          .where('status', isEqualTo: RideStatus.scheduled.name) // Query only "open" rides
          .where('departure_date_time', isGreaterThan: currentTimestamp) // Query only rides in the future
          .orderBy('departure_date_time') // Order by when ride is leaving
          .get();
      notifyListeners();
      return;
    }

    // 1. ToCampus
    if (filters != null) {
      if (filters!['to_campus'] != null) {
        logger.log.fine('RideBoardViewModel Querying - Filters has to_campus: ${filters!['to_campus']}');
        Timestamp currentTimestamp = Timestamp.fromDate(DateTime.now());
        rides = rides
            .where('to_campus', isEqualTo: filters!['to_campus'])
            .where('departure_date_time', isGreaterThan: currentTimestamp)
            .orderBy('departure_date_time');
        notifyListeners();
      }

      // 2. Departure Date
      if (filters!['departure_date_time'] != null) {
        logger.log
            .fine('RideBoardViewModel Querying - Filters has departure_date_time: ${filters!['departure_date_time']}');
        Timestamp departTimeStamp = Timestamp.fromDate(filters!['departure_date_time']);
        Timestamp dayAheadDepartTimeStamp =
            Timestamp.fromDate(filters!['departure_date_time'].add(const Duration(hours: 24)));
        rides = rides
            .where('departure_date_time', isGreaterThanOrEqualTo: departTimeStamp)
            .where('departure_date_time', isLessThanOrEqualTo: dayAheadDepartTimeStamp);
        notifyListeners();
      }

      // Update our QuerySnapshot with the queried data
      querySnapshot = await rides.get();
      return;
    }
  }
}
