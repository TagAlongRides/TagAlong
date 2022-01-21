import 'package:cloud_firestore/cloud_firestore.dart';

/// [DatabaseService] is the main service for our Firebase Cloud Firestore.
///
/// It will contain the API for basic CRUD operations among various collections.
class DatabaseService {

  /// A CollectionReference to our [users] collection.
  final CollectionReference users = FirebaseFirestore.instance.collection('users');


  /// Returns a Future<bool> regarding whether a TagAlong User with document id [uid]
  /// is fully registered.
  Future<bool> isUserRegistered(String uid) async {
    DocumentSnapshot data = await users.doc(uid).get();
    return data.exists;
  }

  Future update_user_data(String? uid, String university, int year, String email, String phone_number) async {
    return await users.doc(uid).set({
      'university': university,
      'grad_year': year,
      'email': email,
      'phone_number': phone_number
    });
  }
}