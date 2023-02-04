import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Cloud Firestore instance - singleton
  final db = FirebaseFirestore.instance;

  // FacebookAuth instance - singleton
  final _fbAuth = FacebookAuth.instance;

  // TagAlongUserNew instance - singleton
  TagAlongUserNew? tagalongUser;

  /// Returns a Stream<User?> on when the user is logged in, out, or just registered.
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Creates a Firebase [User] with the given [email] and [password].
  ///
  /// Returns a Future with a String of the error code of logging in.
  Future<String> createUserWithEmailAndPassword({
    required String email,
    required String password}) async
  {
    // Default creation error code SUCCESS
    String errorCode = Constants.FIREBASE_AUTH_SUCESS;
    try {
      UserCredential userCred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      // Create a "Basic" [TagAlongUser]
      tagalongUser = TagAlongUserNew.fromFireBaseUser(userCred.user!);
    }
    on FirebaseAuthException catch (e) {
      errorCode = e.code;
    }
    return errorCode;
  }

  /// Signs in a user
  Future<String> signInWithFacebook() async {
    String errorCode = Constants.FIREBASE_AUTH_SUCESS;

    // Trigger the sign-in flow
    final LoginResult loginResult = await _fbAuth.login();

    // Update errorCode on failure
    if (loginResult.status != LoginStatus.success) {
      errorCode = "failure";
    }
    else {
      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider
          .credential(loginResult.accessToken!.token);

      // Once signed in, return the UserCredential
      await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    }

    return errorCode;
  }

  void createTagAlongUserFirestore() async {
    TagAlongUserNew tagAlongUserRef = this.tagalongUser!;
    await db.collection('users').doc(tagAlongUserRef.id).set(tagAlongUserRef.toJson());
  }


  /// Signs the User out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}