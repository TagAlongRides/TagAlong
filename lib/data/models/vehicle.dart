// import 'package:tagalong/data/models/ta_data_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// /// [Vehicle] Data model.
// class Vehicle implements TADataModel {

//   final String vehicleId;   // UUID
//   final DateTime createdAt;
//   final String make;
//   final String model;
//   final String year;
//   final String color;

//   Vehicle({
//     required this.createdAt,
//     required this.make,
//     required this.model,
//     required this.year,
//     required this.color,
//     required this.vehicleId
//   });

//   /// A Map<String, dynamic> into a [Vehicle] instance
//   ///
//   /// Assumes that [json] data is always from Firebase, therefore
//   /// `created_at` may be a [Timestamp] or [Datetime],
//   /// since Firebase stores [DateTime] as [TimeStamp]
//   factory Vehicle.fromJson(Map<String, dynamic> json){
//     var createdAt = json['created_at'];
//     if (createdAt == null) {
//       throw UnsupportedError('Invalid - createdAt is $createdAt');
//     }
//     else if (createdAt is Timestamp) {
//       createdAt = createdAt.toDate();
//     }
//     final make = json['make'] as String?;
//     if (make == null) {
//       throw UnsupportedError('Invalid - make is $make');
//     }
//     final model = json['model'] as String?;
//     if (model == null) {
//       throw UnsupportedError('Invalid - model is $model');
//     }
//     final year = json['year'] as String?;
//     if (year == null) {
//       throw UnsupportedError('Invalid - year is $year');
//     }
//     final color = json['color'] as String?;
//     if (color == null) {
//       throw UnsupportedError('Invalid - color is $color');
//     }
//     final vehicleId = json['vehicle_id'] as String?;
//     if (vehicleId == null) {
//       throw UnsupportedError('Invalid - vehicleId is $vehicleId');
//     }
//     return Vehicle(
//       createdAt: createdAt,
//       make: make,
//       model: model,
//       year: year,
//       color: color,
//       vehicleId: vehicleId
//     );

//   }

//   /// A [Vehicle] instance into a Map<String, dynamic>
//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'created_at': createdAt,
//       'make': make,
//       'model': model,
//       'year': year,
//       'color': color,
//       'vehicle_id': vehicleId
//     };
//   }

//   @override
//   String toString() {
//     return "$year $make $model".toUpperCase();
//   }
// }