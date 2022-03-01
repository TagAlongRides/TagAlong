import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/ta_data_model.dart';
import 'package:tagalong/util/user_data.dart';


/// [Ride] data model.
class Ride implements TADataModel {

  final String rideId;        // UUID
  final String driverId;
  final String schoolId;
  final String
  final DateTime createdAt;

}