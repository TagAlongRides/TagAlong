import 'dart:convert';

import 'package:ride_repo/src/enum/ride_booking_status.dart';
import 'package:uuid/uuid.dart';

class RideBookingModel {
  /// [docId] from firebase collection
  String? _rideBookingId;

  /// [rideId] from ride Collcetion
  final String rideId;

  /// [userId] from user profile collection
  final String userId;

  /// [date] when this booking has done
  final DateTime creatadAt;

  /// [date] when this booking has been update like canceled
  DateTime? updatedAt;

  /// bool flag to track if this booking is canceled
  bool? isCanceled;

  ///Stripe Details

  /// Charge Id from Stripe payment
  final String chargeId;

  /// Payment Intent Id from Stripe payment
  final String paymentIntentId;

  /// Status
  RideBookingStatus status;

  RideBookingModel({
    required this.rideId,
    required this.userId,
    required this.creatadAt,
    this.updatedAt,
    this.isCanceled = false,
    required this.chargeId,
    required this.paymentIntentId,
    this.status = RideBookingStatus.active,
  });

  String get rideBookingId => _rideBookingId ??= const Uuid().v4();

  set rideBookingId(String id) {
    _rideBookingId = id;
  }

  Map<String, dynamic> toMap() {
    return {
      'rideBookingId': rideBookingId,
      'rideId': rideId,
      'userId': userId,
      'creatadAt': creatadAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isCanceled': isCanceled,
      'chargeId': chargeId,
      'paymentIntentId': paymentIntentId,
      "status": status.name.toLowerCase(),
    };
  }

  factory RideBookingModel.fromMap(Map<String, dynamic> map) {
    return RideBookingModel(
      rideId: map['rideId'] ?? '',
      userId: map['userId'] ?? '',
      creatadAt: DateTime.fromMillisecondsSinceEpoch(map['creatadAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      isCanceled: map['isCanceled'],
      chargeId: map['chargeId'] ?? '',
      paymentIntentId: map['paymentIntentId'] ?? '',
      status: RideBookingStatus.values
          .byName(map["status"].toString().toLowerCase()),
    )..rideBookingId = map['rideBookingId'];
  }

  String toJson() => json.encode(toMap());

  factory RideBookingModel.fromJson(String source) =>
      RideBookingModel.fromMap(json.decode(source));
}
