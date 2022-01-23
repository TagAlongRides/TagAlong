import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/data/models/user.dart';

/// [DatabaseService] is the main service for our Firebase Cloud Firestore.
///
/// It will contain the API for basic CRUD operations among various collections.
class DatabaseService {

  /// A CollectionReference to our [users] collection.
  final CollectionReference users = FirebaseFirestore.instance.collection(
      'users');

  /// Returns a Future<bool> regarding whether a TagAlong User with document id [uid]
  /// is fully registered, while creating an "Unregistered User" if brand new.
  Future<bool> createUnregisteredUser(String uid) async {
    bool isRegistered = false;
    DocumentSnapshot snapshot = await users.doc(uid).get();

    // 1. `User` does not exist at all - first time usage.
    // Create an "unregistered User", update Firestore, and return false
    if (!snapshot.exists) {
      TagAlongUser user = TagAlongUser(
          uid, DateTime.now(), SignInMethod.facebook);
      await users.doc(uid).set(user.toMap());
      print(
          'DEBUG: Brand new User! Create an Unregistered User with the following: ${user
              .toMap().toString()}');
      return isRegistered;
    }

    // 2. `User` does exist - may or may NOT be registered.
    else if (snapshot.exists) {
      Map<String, dynamic> mapData = snapshot.data() as Map<String, dynamic>;
      print('mapData: ${mapData.toString()}');
      isRegistered = mapData['is_registered'] == 'true';
    }
    return isRegistered;
  }
}