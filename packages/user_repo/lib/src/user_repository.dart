import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tagalong/util/constants.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:user_repo/user_repo.dart';

/// [UserRepository] is a Repository class that facilitates all CRUD functionality
/// related to the main [TagAlongUser].
///
/// It will be the single truth of data in-memory for our [TagAlongUser].
/// This includes authentication, data loading/setup, or anything else that may be needed to help facilitate the
/// [TagAlongUser] singleton.
class UserRepository implements IUserRepository {

  // TagAlongUser instance - singleton
  // "late", must assume user is updated on [loadTagAlongUser]
  late TagAlongUser tagalongUser;

  // FirebaseAuth instance of authentication - singleton
  final _firebaseAuth = FirebaseAuth.instance;

  // Cloud Firestore instance - singleton
  final _db = FirebaseFirestore.instance;

  // FacebookAuth instance - singleton
  final _fbAuth = FacebookAuth.instance;


  /// Returns the in-memory [tagalongUser]
  @override
  TagAlongUser getTagAlongUser() {
    return tagalongUser;
  }

  /// Returns the in-memory FirebaseAuth.currentUser!
  @override
  User getFirebaseUser() {
    return _firebaseAuth.currentUser!;
  }

  /// Returns the [TagAlongUser] instance and updates the in-memory instance.
  /// May return null if current user is NOT logged in - should only be called
  /// when user is logged in.
  @override
  Future<TagAlongUser> loadTagAlongUser() async {

    // Check if user is logged out - SHOULD NEVER HAPPEN
    if (_firebaseAuth.currentUser == null) {
      logger.log.severe('getTagAlongUser() was called, but user is logged out');
    }

    // Query TagAlongUser from Firestore
    try {
      // 100% logged in
      final User user = _firebaseAuth.currentUser!;
      final CollectionReference usersRef = _db.collection("users");
      final DocumentReference userRef = usersRef.doc(user.uid);

      // Query [usersRef] collection for user
      DocumentSnapshot userSnapShot = await userRef.get();

      // [TagAlongUser] exists in Firestore - get a [TagAlongUser] instance
      if (userSnapShot.exists) {
        logger.log.fine('loadTagAlongUser() - user does exist, retrieving document');
        Map<String, dynamic> data = userSnapShot.data() as Map<String, dynamic>;
        tagalongUser = TagAlongUser.fromJson(data);
      }
      // [TagAlongUser] does NOT exist in Firestore (registering 1st time)
      // Upload new [TagAlongUser] to Firestore
      else {
        logger.log.fine('loadTagAlongUser() - user does NOT exist, creating document in Firestore');
        tagalongUser = TagAlongUser.fromFireBaseUser(user);
        Map<String, dynamic> data = tagalongUser.toJson();
        await userRef.set(data);
      }
      logger.log.fine('loadTagAlongUser() - Firebase User JSON - ${user.toString()}');
    } catch (e) {
      logger.log.severe('$e');
    }

    logger.log.fine('loadTagAlongUser() - all done - ${tagalongUser.toJson()}');
    return tagalongUser;
  }

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
      UserCredential userCred = await _firebaseAuth
          .createUserWithEmailAndPassword(
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

  /// Asynchronously signs in a user, returning an error code describing the
  /// status of the "sign in".
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

  /// Registers the TagAlongUser, updating Firestore `users` collection and
  /// updates the Firebase User's "email" for verification purposes.
  Future<bool> registerTagAlongUser({
    required String name,
    required String emailAddress,
    required String? gradYear}) async {
    // Update [tagalongUser]
    tagalongUser.isRegistered = true;
    tagalongUser.name = name;
    tagalongUser.emailAddress = emailAddress;
    tagalongUser.graduationYear = gradYear;

    // Update Firebase User's email
    await _firebaseAuth.currentUser!.updateEmail(emailAddress);
    logger.log.fine('registerTagAlongUser() - Updated Firebase User with email $emailAddress');

    final CollectionReference usersRef = _db.collection("users");
    final DocumentReference userRef = usersRef.doc(tagalongUser.id);

    logger.log.fine('registerTagAlongUser() - registering user');
    Map<String, dynamic> data = tagalongUser.toJson();
    await userRef.set(data);
    logger.log.fine('registerTagAlongUser() - user ${tagalongUser.id} fully registered');

    return true;
  }

  /// Sends a verification email to the Firebase User's email.
  Future<bool> sendEmailVerificationToUser() async {
    bool sentVerification = false;
    User user = _firebaseAuth.currentUser!;

    // Refresh currently logged in User
    // user.reload();

    // Basic check to see if [tagalongUser] is "registered"
    if (tagalongUser.isRegistered == false) {
      logger.log.severe('User ${tagalongUser.id} is NOT registered!');
    }

    // Check if already has verified their email
    else {
      logger.log.fine('sendEmailVerificationToUser() - User ${tagalongUser.id} is registered');

      // is email verified
      if (user.emailVerified == true) {
        logger.log.severe('sendEmailVerificationToUser() - User ${tagalongUser.id} is verified!');
      }

      // is NOT verified
      else {
        logger.log.fine('sendEmailVerificationToUser() - Sending a verification email to ${tagalongUser.id}');
        await user.sendEmailVerification();
        sentVerification = true;
      }
    }

    return sentVerification;
  }

  /// Signs the User out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Reloads the [User] from FirebaseAuth - used for token and email updates
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser!.reload();
  }
}
