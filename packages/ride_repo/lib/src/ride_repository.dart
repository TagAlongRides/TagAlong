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

  static RideRepository get instance =>
      _instance ??= RideRepository._internal();

  RideRepository._internal();

  final rideBookingCollection = FirebaseFirestore.instance.collection('rides');

  /// get the ride booking with docId
  Future<List<RideModel>> getMyOfferedRides(String userId) async {
    try {
      final querySnapshot = await rideBookingCollection
          .where('driver_id', isEqualTo: userId)
          .get();
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
      final querySnapshot =
          await rideBookingCollection.where('ride_id', isEqualTo: rideId).get();
      return RideModel.fromJson(querySnapshot.docs.first.data());
    } catch (error) {
      throw RideException(ErrorModel.firebaseError(error.toString()));
    }
  }

  /// update the ride booking
  Future<RideModel> updateRide(RideModel model) async {
    try {
      model.updatedAt = DateTime.now();
      await rideBookingCollection.doc(model.rideId).update(model.toJson());
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
}
