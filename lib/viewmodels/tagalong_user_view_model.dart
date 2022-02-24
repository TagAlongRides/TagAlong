import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/util/log.dart' as logger;

/// [TagAlongUser] ViewModel which contains business logic.
class TagAlongUserViewModel {

  TagAlongUser? tagAlongUser;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  /// Getter for DatabaseService
  DatabaseService get databaseService => _databaseService;

  /// Getter for DatabaseService
  AuthService get authService => _authService;

  /// Returns a unique String UID for a TagAlongUser
  String? getUid() {
    String? uid = _authService.getUid();
    logger.log.fine('getUid() - $uid');
    return uid;
  }

  /// Returns the current [User] if they are currently signed-in, or `null` if
  /// not.
  User? getUser() {
    return _authService.getUser();
  }

  /// Sends a Email verification to [TagAlongUser] `email` as well as
  /// updates the [TagAlongUser] `email`
  Future<void> sendEmailVerificationToUser() async {
    if (userExists()) {
      String? studentEmail = tagAlongUser?.emailAddress;
      User? user = getUser();
      if (studentEmail != null && user != null) {
        // TODO: Need to reauthenticate our Firebase `User` again because updating - Firebase security sensitive.
        // TODO: For now, just always sign-in AND register..
        await user.reload();
        await user.updateEmail(studentEmail);
        await user.sendEmailVerification();
        logger.log.fine('sendEmailVerificationToUser() - Sent verification email to $studentEmail');
      }
    }
    else {
      logger.log.fine('sendEmailVerificationToUser() - User does NOT exist, how is this possible?');
    }
  }

  /// Returns a bool? on whether our [tagAlongUser] instance is registered.
  bool? isRegistered() {
    if (userExists()) {
      return tagAlongUser!.registered;
    }
    else {
      return null;
    }
  }

  /// Returns a bool on whether [tagAlongUser] instance exists (in-memory).
  bool userExists() {
    if (tagAlongUser == null) {
      return false;
    }
    else {
      return true;
    }
  }

  // TODO: Will most likely need to add a "provider" login parameter.
  // TODO: Error handling
  /// Triggers a Facebook Sign-in event via [AuthService].
  ///
  /// If successful, build an unregistered [User] and store in Firestore.
  /// Else, convey error messages appropriately.
  Future<void> createOrSignIn() async {
    // Perform the Facebook login
    UserCredential? userCred = await _authService.facebookLogin();

    // 1. User successfully logged into Facebook and
    // has created or has an entry in FirebaseAuth
    if (userCred != null) {
      if (userCred.user != null) {
        // Extract the `uid` from the `UserCredential.User?`
        String uid = userCred.user!.uid;
        // Set up our [TagAlongUser] instance
        await setUpUser(uid);
      }
    }

    // 2. User unsuccessful in Facebook Login
    else {
      return;
    }
  }

  /// Sets up this ViewModel's [TagAlongUser] instance.
  ///
  /// This [TagAlongUser] may or may-not exist in the Firestore, however the
  /// user must exist within the FirebaseAuth system.
  /// If the User exists, pull data and populate `user`.
  /// If the User !exist, create an "unregistered User" and write to Firestore.
  Future<void> setUpUser(String uid, {String signInMethod = SignInMethod.FACEBOOK}) async {
    logger.log.fine('setUpUser()');
    // 1. [user] exists in memory
    if (tagAlongUser != null) {
      logger.log.fine('setUpUser() - TagAlongUser instance already in memory.');
      return;
    }

    // 2. [user] does NOT exist in memory
    else {
      // Query `users` collection for [uid] user and see if they exist
      logger.log.fine('setUpUser() - Querying data for user $uid');
      DocumentSnapshot snapshot = await databaseService.users.doc(uid).get();

      // User exists - initialize our TagAlongUser `user` instance and return
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        logger.log.fine('setUpUser() - User exists! Looks like:');
        logger.log.fine('setUpUser() - ${userData.toString()}');
        tagAlongUser = TagAlongUser.fromJson(userData);
        return;
      }
      // User does not exist - create an unregisteredUser and add to Firestore
      // as an "Unregistered TagAlongUser"
      else {
        logger.log.fine('setUpUser() - User did not exist!');
        final time = DateTime.now();
        tagAlongUser = TagAlongUser(
          id: uid,
          createdAt: time,
          updatedAt: time,
        );
      }
      logger.log.fine('setUpUser() - TagAlongUser was initialized.');
      logger.log.fine('setUpUser() - The TagAlongUser is: $tagAlongUser}');
      await addTagAlongUserToFirestore(uid);
    }
  }

  /// Updates our TagAlongUser instance's `driverData`
  void updateDriverData(Driver driverData) {
    if (userExists()) {
      tagAlongUser!.driverData = driverData;
    }
    else {

    }
  }

  /// Adds a [TagAlongUser] to the Firestore `users` collection.
  Future<void> addTagAlongUserToFirestore(String uid) async {
    if (userExists()) {
      await databaseService.users.doc(uid).set(tagAlongUser!.toJson());
      logger.log.fine('addTagAlongUserToFirestore() - Added TagAlongUser $uid.');
    }
    else {
      logger.log.fine('addTagAlongUserToFirestore() - TagAlongUser instance does not exist in ViewModel; cannot happen');
    }
  }

  /// Updates this instance's [TagAlongUser] in-memory only
  void updateTagAlongUserInternal(Map<String, dynamic> data) {
    tagAlongUser?.updateTagAlongUser(data);
    logger.log.fine('updateTagAlongUserInternal() - TagAlongUser after update:\n'
        '$tagAlongUser');
  }

  /// Updates the Firebase with this ViewModel's current instance of [user]
  ///
  /// Does not replace existing values
  Future<void> updateTagAlongUserFirestore() async {
    Map<String, dynamic> tagAlongUserData = tagAlongUser!.toJson();
    await _databaseService.users.doc(getUid()).update(tagAlongUserData);
    logger.log.fine('updateTagAlongUser(): jsonData - $tagAlongUserData');

  }


}