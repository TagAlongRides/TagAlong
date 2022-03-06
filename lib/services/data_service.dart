import 'package:cloud_firestore/cloud_firestore.dart';

/// [DatabaseService] is the main service for our Firebase Cloud Firestore.
///
/// It will contain references to various collections.
class DatabaseService {

  /// A CollectionReference to our [users] collection.
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  /// A CollectionReference to our [rides] collection.
  final CollectionReference rides = FirebaseFirestore.instance.collection('rides');
}