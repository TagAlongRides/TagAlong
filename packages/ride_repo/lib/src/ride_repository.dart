import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:ride_repo/src/model/model.dart';

class RideException implements Exception {
  final ErrorModel error;

  RideException(this.error);

  @override
  String toString() => error.message;
}

class RideRepository {
  static RideRepository? _instance;

  static RideRepository get instance => _instance ??= RideRepository._internal();

  RideRepository._internal();

  final rideCollection = FirebaseFirestore.instance.collection('rides');
  final rideBookingCollection = FirebaseFirestore.instance.collection('rideBooking');

  /// get the ride booking with docId
  Future<List<RideModel>> getMyOfferedRides(String userId) async {
    try {
      final querySnapshot = await rideCollection.where('driver_id', isEqualTo: userId).get();
      return await Stream.fromIterable(querySnapshot.docs)
          .asyncMap((event) => RideModel.fromJson(event.data()))
          .toList();
    } catch (error) {
      throw RideException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// Get the ride model using ride Id
  Future<RideModel> getRideById(String rideId) async {
    try {
      final querySnapshot = await rideCollection.where('ride_id', isEqualTo: rideId).get();
      return RideModel.fromJson(querySnapshot.docs.first.data());
    } catch (error) {
      throw RideException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// update the ride booking
  Future<RideModel> updateRide(RideModel model) async {
    try {
      model.updatedAt = DateTime.now();
      await rideCollection.doc(model.rideId).update(model.toJson());
      return model;
    } catch (error) {
      throw RideException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// Cancel the ride
  Future<RideModel> cancelRide(RideModel model) async {
    try {
      model.status = RideStatus.canceled;
      model = await updateRide(model);
      return model;
    } on HttpApiException catch (error) {
      throw RideBookingException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  Future<List<RideModel>> getBookedRidesForUser(String userId) async {
    try {
      // Find user ride bookings and get corresponding ride IDs
      var bookingData = await rideBookingCollection.where('userId', isEqualTo: userId).get();
      // A user can book the same ride more than once (e.g. cancel and rebook), so de-duplicate.
      final rideIds = bookingData.docs
          .map((booking) => booking.data()['rideId'])
          .whereType<String>()
          .toSet()
          .toList();

      // Firestore rejects a 'whereIn' filter with an empty list, so a user with no
      // bookings has no booked rides rather than an error.
      if (rideIds.isEmpty) return [];

      // 'whereIn' accepts at most 30 values per query, so query in chunks.
      const whereInLimit = 30;
      final List<RideModel> bookedRides = [];
      for (var start = 0; start < rideIds.length; start += whereInLimit) {
        final end = start + whereInLimit < rideIds.length ? start + whereInLimit : rideIds.length;
        final chunk = rideIds.sublist(start, end);
        final snapshot = await rideCollection.where('ride_id', whereIn: chunk).get();
        bookedRides.addAll(snapshot.docs.map((ride) => RideModel.fromJson(ride.data())));
      }
      return bookedRides;
    } catch (error) {
      throw RideException(ErrorModel.firebaseError(error.toString()));
    }
  }

  Future<List<RideModel>> getAllRidesForUser(String userId, {bool? ordered}) async {
    try {
      // Get lists of rides where user is the driver and rider
      final ridesDriver = await getMyOfferedRides(userId);
      final ridesPassenger = await getBookedRidesForUser(userId);

      // Combine both lists, keeping one entry per ride in case a ride appears in both
      final ridesById = <String, RideModel>{};
      for (final ride in [...ridesDriver, ...ridesPassenger]) {
        ridesById.putIfAbsent(ride.rideId, () => ride);
      }
      final List<RideModel> allRides = ridesById.values.toList();

      // Sort descending by ride departure time if ordered = true
      if (ordered ?? false) {
        allRides.sort((a, b) => b.departureDateTime.compareTo(a.departureDateTime));
      }
      return allRides;
    } on RideException {
      rethrow;
    } catch (error) {
      throw RideException(ErrorModel.firebaseError(error.toString()));
    }
  }
}
