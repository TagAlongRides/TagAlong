import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
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
  List<RideModel>? querySnapshotMap;

  /// Updates this instance's [filters] and notifies listeners,
  /// mainly for the [RideBoard] so that it will re-update with new Rides
  /// once a user clicks "Filter" button
  void updateFilters(Map<String, dynamic> filters) {
    this.filters = filters;
    notifyListeners();
  }

  /// Returns a Future<QuerySnapshot<Map<String, dynamic>>> of ALL rides
  /// ordered by the `departure_date_time` field, from `rides` collection.

  Future<List<RideModel>> getAllRidesData() async {
    try {
      final rideData = await HttpApiClient.instance.get('rideboard/');

      if (rideData['message'] == 'Rideboard rides successfully retrieved - no rides found') {
        return [];
      }
      final rideDataParsed = (rideData['data'] as List<dynamic>).map((ride) {
        final rideMap = ride as Map<String, dynamic>;
        return RideModel.fromJson(rideMap);
      }).toList();

      querySnapshotMap = rideDataParsed;
      return rideDataParsed;
    } on Exception catch (e) {
      logger.log.fine(e.toString());
      return [];
    }
  }

  /// Asynchronously updates our current QuerySnapshot, which contains the result of the last
  /// query we had, based on the user's filters.
  Future<List<RideModel>> getRidesBasedOnFilters() async {
    // Get all available rides
    List<RideModel> ridesToReturn = await getAllRidesData();

    // Exclude results where the user is the driver or has already booked
    final userId = authService.getUser()!.uid;
    ridesToReturn = ridesToReturn.where((ride) => ride.driverId != userId && !ride.riderIds.contains(userId)).toList();

    // Filter ride results based on the filters applied by the user
    if (filters == null) {
      logger.log.fine('RideBoardViewModel Querying - Filters is NULL');
    } else {
      // 1. ToCampus
      if (filters!['to_campus'] != null) {
        logger.log.fine('RideBoardViewModel Querying - Filters has to_campus: ${filters!['to_campus']}');
        ridesToReturn = ridesToReturn.where((ride) => ride.toCampus == filters!['to_campus']).toList();
      }

      // 2. Departure Date
      if (filters!['departure_date_time'] != null) {
        logger.log
            .fine('RideBoardViewModel Querying - Filters has departure_date_time: ${filters!['departure_date_time']}');
        DateTime departTimeStamp = filters!['departure_date_time'];
        DateTime dayAheadDepartTimeStamp = filters!['departure_date_time'].add(const Duration(hours: 24));
        ridesToReturn = ridesToReturn
            .where((ride) =>
                ride.departureDateTime.isAfter(departTimeStamp.subtract(const Duration(seconds: 1))) &&
                ride.departureDateTime.isBefore(dayAheadDepartTimeStamp.add(const Duration(seconds: 1))))
            .toList();
      }
    }
    // Return our results with filters applied
    ridesToReturn.sort((ride1, ride2) => ride1.departureDateTime.compareTo(ride2.departureDateTime));
    return ridesToReturn;
    //'departure_date_time'
  }
}
