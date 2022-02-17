import 'package:tagalong/data/models/vehicle.dart';

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
  Driver.fromJson(Map<String, dynamic> json):
      createdAt = json['created_at'].toDate(),
      vehicle = json['vehicle'],
      isActive = json['is_active'];

  /// A [Driver] instance into a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'create_at': createdAt,
      'vehicle': vehicle.toJson(),
      'is_active': isActive
    };
  }

  @override
  String toString() {
    return 'Driver with vehicle ${vehicle.toString()}';
  }


}