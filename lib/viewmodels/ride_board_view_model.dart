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

  List<RideModel>? results;

  /// Updates this instance's [filters] and notifies listeners,
  /// mainly for the [RideBoard] so that it will re-update with new Rides
  /// once a user clicks "Filter" button
  void updateFilters(Map<String, dynamic> filters) {
    this.filters = filters;
    notifyListeners();
  }

  /// Gets all rides available to book from cloud function (status is scheduled, has available seat)
  /// Parses results to RideModel
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

      results = rideDataParsed;
      return rideDataParsed;
    } on Exception catch (e) {
      logger.log.fine(e.toString());
      return [];
    }
  }

  /// Retrieves list of RideModels from getAllRidesData() and applies user-selected filters
  Future<List<RideModel>> getRidesBasedOnFilters() async {
    // Get all available rides
    List<RideModel> ridesToReturn = await getAllRidesData();
    logger.log.fine('Rideboard filters applied: ${filters.toString()}');

    // Exclude results where the user is the driver or has already booked
    final userId = authService.getUser()!.uid;
    ridesToReturn = ridesToReturn.where((ride) => ride.driverId != userId && !ride.riderIds.contains(userId)).toList();

    // Filter ride results based on the filters applied by the user
    if (filters != null) {
      // 1. ToCampus
      final toCampusFilter = filters?['to_campus'];
      final fromCampusFilter = filters?['from_campus'];
      if (toCampusFilter != fromCampusFilter) {
        ridesToReturn = ridesToReturn.where((ride) => ride.toCampus == toCampusFilter).toList();
      }

      // 2. Departure Date
      if (filters!['departure_date_time'] != null) {
        DateTime filterDateTime = filters!['departure_date_time'];
        ridesToReturn =
            ridesToReturn.where((ride) => ride.departureDateTime.toDate() == filterDateTime.toDate()).toList();
      }
    }
    // Return our results with filters applied
    ridesToReturn.sort((ride1, ride2) => ride1.departureDateTime.compareTo(ride2.departureDateTime));
    return ridesToReturn;
  }
}
