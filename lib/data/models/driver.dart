import 'package:tagalong/data/models/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// [Driver] Data model.
class Driver {
  final DateTime createdAt;
  Vehicle vehicle;
  bool isActive;

  Driver({
      required this.createdAt,
      required this.vehicle,
      this.isActive=false
    });

  /// A Map<String, dynamic> into a [Driver] instance.
  ///
  /// Assumes that [json] data is always from Firebase, therefore
  /// `created_at` may be a [Timestamp] or [Datetime],
  /// since Firebase stores [DateTime] as [TimeStamp]
  factory Driver.fromJson(Map<String, dynamic> json) {
    var createdAt = json['created_at'];
    if (createdAt == null) {
      throw UnsupportedError('Invalid - createdAt is $createdAt');
    }
    else if (createdAt is Timestamp) {
      createdAt = createdAt.toDate();
    }
    var vehicle = json['vehicle'];
    if (vehicle == null) {
      throw UnsupportedError('Invalid - vehicle is $vehicle');
    }
    else {
      vehicle = Vehicle.fromJson(json['vehicle']);
    }
    final isActive = json['is_active'] ?? false;
    return Driver(
      createdAt: createdAt,
      vehicle: vehicle,
      isActive: isActive
    );
  }

  /// A [Driver] instance into a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'vehicle': vehicle.toJson(),
      'is_active': isActive
    };
  }

  @override
  String toString() {
    return 'Driver with vehicle ${vehicle.toString()}';
  }
}