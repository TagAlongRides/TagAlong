import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/data/models/ta_data_model.dart';

/// [Driver] Data model.
class Driver implements TADataModel {
  final DateTime createdAt;
  Vehicle vehicle;
  bool isActive;
  bool isStripeActive;
  String? stripeAccountId;

  Driver({
    required this.createdAt,
    required this.vehicle,
    this.isActive = false,
    this.isStripeActive = false,
    this.stripeAccountId,
  });

  /// A Map<String, dynamic> into a [Driver] instance.
  ///
  /// Assumes that [json] data is always from Firebase, therefore
  /// `created_at` may be a [Timestamp] or [DateTime],
  /// since Firebase stores [DateTime] as [TimeStamp]
  factory Driver.fromJson(Map<String, dynamic> json) {
    var createdAt = json['created_at'];
    if (createdAt == null) {
      throw UnsupportedError('Invalid - createdAt is $createdAt');
    } else if (createdAt is Timestamp) {
      createdAt = createdAt.toDate();
    }

    var vehicle = json['vehicle'];
    if (vehicle == null) {
      throw UnsupportedError('Invalid - vehicle is $vehicle');
    } else {
      vehicle = Vehicle.fromJson(json['vehicle']);
    }

    final isActive = json['is_active'] ?? false;

    final isStripeActive = json['is_stripe_active'] ?? false;

    return Driver(
        createdAt: createdAt,
        vehicle: vehicle,
        isActive: isActive,
        isStripeActive: isStripeActive,
        stripeAccountId: json['stripe_account_id']);
  }

  /// A [Driver] instance into a Map<String, dynamic>
  @override
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'vehicle': vehicle.toJson(),
      'is_active': isActive,
      'is_stripe_active': isStripeActive,
      'stripe_account_id': stripeAccountId,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
