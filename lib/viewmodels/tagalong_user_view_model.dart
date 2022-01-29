import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    logger.log.fine('DEBUG: getUid() - $uid');
    return uid;
  }

  /// Returns a bool? on whether our [tagAlongUser] instance is registered.
  bool? isRegistered() {
    if (userExists()) {
      return tagAlongUser!.isRegistered();
    }
    else {
      return null;
    }
  }

  /// Returns a bool on whether [tagAlongUser] instance exists.
  bool userExists() {
    if (tagAlongUser == null) {
      return false;
    }
    else {
      return true;
    }
  }

  // TODO: Will most likely need to add a "provider" login parameter
  /// Triggers a Facebook Sign-in event via [AuthService].
  ///
  /// If successful, build a unregistered [User] and store in Firestore.
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
  Future<void> setUpUser(String uid, {SignInMethod signInMethod = SignInMethod.facebook}) async {
    logger.log.fine('DEBUG: setUpUser()');
    // Check if [user] exists in memory
    if (tagAlongUser != null) {
      logger.log.fine('DEBUG: TagAlongUser instance already in memory.');
      return;
    }
    else {
      // Query `users` collection for [uid] user and see if they exist
      DocumentSnapshot snapshot = await databaseService.users.doc(uid).get();

      // User exists - initialize our TagAlongUser `user` instance
      if (snapshot.exists) {
        Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
        logger.log.fine('DEBUG: data exists! Looks like:');
        logger.log.fine('${userData.toString()}');
        // Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.data);
        tagAlongUser = TagAlongUser.fromJson(userData!);
        logger.log.fine('DEBUG: User exists!');
        // tagAlongUser = TagAlongUser.fromJson(userData);
        // logger.log.fine('DEBUG: User exists!');
      }
      // User does not exist - create an unregisteredUser
      else {
        tagAlongUser = TagAlongUser.unregisteredUser(uid, DateTime.now(), signInMethod);
        logger.log.fine('DEBUG: User did not exist!');
      }
      logger.log.fine('DEBUG: TagAlongUser was initialized.');
      logger.log.fine('The TagAlongUser is: ${tagAlongUser?.toMap().toString()}');
      await addUserToFirestore(uid);

    }
  }

  /// Adds a [TagAlongUser] to the Firestore `users` collection.
  Future<void> addUserToFirestore(String uid) async {
    if (userExists()) {
      await databaseService.users.doc(uid).set(tagAlongUser!.toMap());
      logger.log.fine('DEBUG: Added TagAlongUser ${uid}.');
    }
    else {
      logger.log.fine('DEBUG: TagAlongUser does not exist in ViewModel.');
    }
  }

  Future<void> updateTagAlongUser(Map<String, dynamic> jsonData) async {
    await _databaseService.users.doc(getUid()).update(jsonData);
  }


}