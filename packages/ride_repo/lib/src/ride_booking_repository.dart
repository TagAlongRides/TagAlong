import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:ride_repo/ride_repo.dart';

class RideBookingException implements Exception {
  final ErrorModel error;

  RideBookingException(this.error);

  @override
  String toString() => error.message;
}

class RideBookingRepository {
  static RideBookingRepository? _instance;

  static RideBookingRepository get instance => _instance ??= RideBookingRepository._internal();

  RideBookingRepository._internal();

  final rideBookingCollection = FirebaseFirestore.instance.collection('rideBooking');

  /// book the ride with all the details
  Future<RideBookingModel> bookRide(RideBookingModel model) async {
    try {
      await rideBookingCollection.doc(model.rideBookingId).set(model.toMap());
      return model;
    } catch (error) {
      throw RideBookingException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// get the ride booking with docId
  Future<RideBookingModel> getRideBooking(String docId) async {
    try {
      final docSnapshot = await rideBookingCollection.doc(docId).get();
      return RideBookingModel.fromMap(docSnapshot.data()!);
    } catch (error) {
      throw RideBookingException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// listen the ride booking with docId
  Stream<RideBookingModel> listenRideBooking(String docId) {
    try {
      return rideBookingCollection.doc(docId).snapshots().map((event) => RideBookingModel.fromMap(event.data()!));
    } catch (error) {
      throw RideBookingException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// update the ride booking
  Future<RideBookingModel> updateRideBooking(RideBookingModel model) async {
    try {
      model.updatedAt = DateTime.now();
      log('Updating in Firebase: ${model.toJson()}');
      await rideBookingCollection.doc(model.rideBookingId).update(model.toMap());
      return model;
    } catch (error) {
      throw RideBookingException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// Cancel the ride booking
  Future<RideBookingModel> cancelRideBooking(RideBookingModel model) async {
    try {
      model.isCanceled = true;
      model.status = RideBookingStatus.canceled;
      log('Updating in local memory: ${model.toJson()}');
      var bookingModel = await updateRideBooking(model);
      return bookingModel;
    } on HttpApiException catch (error) {
      throw RideBookingException(error.error);
    } catch (error) {
      rethrow;
    }
  }

  /// get the all ride booking belong to ride id
  /// to get all the rides pass [isCanceled] as null
  Future<List<RideBookingModel>> getRideBookingForRideId(String rideId, {bool? isCanceled = false}) async {
    try {
      if (isCanceled != null) {
        final querySnapshot = await rideBookingCollection
            .where('rideId', isEqualTo: rideId)
            .where('isCanceled', isEqualTo: isCanceled)
            .get();
        return await Stream.fromIterable(querySnapshot.docs)
            .asyncMap<RideBookingModel>(
              (event) => RideBookingModel.fromMap(event.data()),
            )
            .toList();
      } else {
        final querySnapshot = await rideBookingCollection.where('rideId', isEqualTo: rideId).get();
        return await Stream.fromIterable(querySnapshot.docs)
            .asyncMap<RideBookingModel>(
              (event) => RideBookingModel.fromMap(event.data()),
            )
            .toList();
      }
    } catch (error) {
      throw RideBookingException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// get the all ride booking belong to user id
  Future<List<RideBookingModel>> getRideBookingForUser(String userId, {bool isCanceled = false}) async {
    try {
      final querySnapshot = await rideBookingCollection
          .where('userId', isEqualTo: userId)
          .where('isCanceled', isEqualTo: isCanceled)
          .get();
      return await Stream.fromIterable(querySnapshot.docs)
          .asyncMap<RideBookingModel>(
            (event) => RideBookingModel.fromMap(event.data()),
          )
          .toList();
    } catch (error) {
      throw RideBookingException(ErrorModel.firebaseError(error.toString()));
    }
  }

  // Get the ride bookings for a user related to a particular ride
  Future<List<RideBookingModel>> getBookingsForRideAndUser({
    required String rideId,
    required String userId,
    bool isCanceled = false,
  }) async {
    try {
      final querySnapshot = await rideBookingCollection
          .where('rideId', isEqualTo: rideId)
          .where('userId', isEqualTo: userId)
          .where('isCanceled', isEqualTo: isCanceled)
          .get();
      return await Stream.fromIterable(querySnapshot.docs)
          .asyncMap<RideBookingModel>(
            (event) => RideBookingModel.fromMap(event.data()),
          )
          .toList();
    } catch (error) {
      throw RideBookingException(ErrorModel.firebaseError(error.toString()));
    }
  }
}
