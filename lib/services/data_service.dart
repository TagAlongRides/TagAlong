import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/data/models/user.dart';

/// [DatabaseService] is the main service for our Firebase Cloud Firestore.
///
/// It will contain references to various collections.
class DatabaseService {

  /// A CollectionReference to our [users] collection.
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

}