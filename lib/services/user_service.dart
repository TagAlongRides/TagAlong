import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tagalong/data/models/tagalong_user_new.dart';

/// [UserService] is a service class that facilitates all functionality related to the main [TagAlongUser].
///
/// It will be the single truth of data in-memory for our [TagAlongUser].
/// This includes authentication, data loading/setup, or anything else that may be needed to help facilitate the
/// [TagAlongUser] singleton.
class UserService {

  // FirebaseAuth instance of authentication - singleton
  final _firebaseAuth = FirebaseAuth.instance;
  final _fb = FacebookAuth.instance;

  // TagAlongUserNew instance - singleton
  TagAlongUserNew? tagalongUser;


  /// Returns a Stream<User?> on when the user is logged in, out, or just registered.
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password}) async
  {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }
  }

}