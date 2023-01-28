import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tagalong/data/models/tagalong_user_new.dart';
import 'package:tagalong/util/constants.dart';
import 'package:tagalong/util/log.dart' as logger;

/// [UserService] is a service class that facilitates all functionality related to the main [TagAlongUser].
///
/// It will be the single truth of data in-memory for our [TagAlongUser].
/// This includes authentication, data loading/setup, or anything else that may be needed to help facilitate the
/// [TagAlongUser] singleton.
class UserService {

  // FirebaseAuth instance of authentication - singleton
  final _firebaseAuth = FirebaseAuth.instance;
  final _fbAuth = FacebookAuth.instance;

  // TagAlongUserNew instance - singleton
  TagAlongUserNew? tagalongUser;


  /// Returns a Stream<User?> on when the user is logged in, out, or just registered.
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Creates a Firebase [User] with the given [email] and [password]
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password}) async
  {
    String errorCode = Constants.FIREBASE_AUTH_SUCESS;
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      print('created user');
    }
    on FirebaseAuthException catch (e) {
      errorCode = e.code;
    }
    return errorCode;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}