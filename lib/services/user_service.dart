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

  // ! IMPORTANT ! - initialized "late" in [loadTagAlongUser]
  // TagAlongUserNew instance - singleton
  late TagAlongUserNew tagalongUser;

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
    }
    on FirebaseAuthException catch (e) {
      errorCode = e.code;
    }
    return errorCode;
  }

  /// Signs in a Firebase [User] with the given [email] and [password].
  ///
  /// Returns a Future with a String of the error code of logging in.
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password}) async
  {
    // Default creation error code SUCCESS
    String errorCode = Constants.FIREBASE_AUTH_SUCESS;
    try {
      UserCredential userCred = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
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

  /// Loads the [tagalongUser] in-memory as a singleton in this class.
  ///
  /// This will be called in [RegistrationGate], hence [tagalongUser] can be used freely and is type-safe against null.
  /// Returns true is user was successfully loaded in, else false.
  Future<bool> loadTagAlongUser() async {
    bool wasLoaded = true;

    try {
      final User user = _firebaseAuth.currentUser!;
      final CollectionReference usersRef = db.collection("users");
      final DocumentReference userRef = usersRef.doc(user.uid);

      // Query [usersRef] collection for user
      DocumentSnapshot userSnapShot = await userRef.get();
      logger.log.fine('loadTagAlongUser() - ${userSnapShot.data()}');

      // [TagAlongUser] exists in Firestore - get a [TagAlongUserNew] instance
      if (userSnapShot.exists) {
        Map<String, dynamic> data = userSnapShot.data() as Map<String, dynamic>;
        tagalongUser = TagAlongUserNew.fromJson(data);
      }
      // [TagAlongUser] does NOT exist in Firestore (registering 1st time)
      // Upload new [TagAlongUserNew] to Firestore
      else {
        tagalongUser = TagAlongUserNew.fromFireBaseUser(user);
        Map<String, dynamic> data = tagalongUser.toJson();
        userRef.set(data);
      }
    } catch (e) {
      logger.log.severe('$e');
      wasLoaded = false;
    }

    return wasLoaded;
  }

  /// Signs the User out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}