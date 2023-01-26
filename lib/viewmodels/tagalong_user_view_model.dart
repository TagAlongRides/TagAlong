import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/user_data.dart';


class TagAlongUserViewModel with ChangeNotifier {

  /// The [TagAlongUser] data model
  TagAlongUser? tagAlongUser;

  /// The [FirebaseAuth] singleton used to check our Firebase User
  final _firebaseAuth = FirebaseAuth.instance;

  /// The [FacebookAuth] singleton used to facilitate Facebook SSO
  final _fbAuth = FacebookAuth.instance;

  TagAlongUserViewModel({this.tagAlongUser});


  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  /// Getter for DatabaseService
  DatabaseService get databaseService => _databaseService;

  /// Getter for AuthService
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
    authService.getUser()?.reload();
    if (userExists()) {
      String? studentEmail = tagAlongUser?.emailAddress;
      User? user = getUser();
      if (studentEmail != null && user != null) {
        try {
          await user.reload();
          // await user.updateEmail(studentEmail);
          if (studentEmail == user.email && user.emailVerified) {
            logger.log.fine('No email verification sent: User already authenticated');
            return;
          }
          if (studentEmail == user.email) {
            logger.log.fine('Sending email verification');
            await user.sendEmailVerification();
          } else {
            logger.log.fine('Reauthenticating user');
            final authToken = await FacebookAuth.instance.accessToken;
            final facebookAuthCredential = FacebookAuthProvider.credential(authToken!.token);
            await user.reauthenticateWithCredential(facebookAuthCredential);
            logger.log.fine('Sending email verification to updated email');
            await user.verifyBeforeUpdateEmail(studentEmail);
          }
        } catch (e) {
          logger.log.fine('Email verification failed: ${e.toString()}');
        }
        logger.log.fine('sendEmailVerificationToUser() - Sent verification email to $studentEmail');
      }
    } else {
      logger.log.fine('sendEmailVerificationToUser() - User does NOT exist, how is this possible?');
    }
  }

  /// Returns a bool? on whether our [tagAlongUser] instance is registered.
  bool? isRegistered() {
    if (userExists()) {
      return tagAlongUser!.registered;
    } else {
      return null;
    }
  }

  /// Returns a bool on whether [tagAlongUser] instance exists (in-memory).
  bool userExists() {
    if (tagAlongUser == null) {
      return false;
    } else {
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
        await setUpUser(uid, signInMethod: SignInMethod.FACEBOOK);
      }
    }
    // 2. User unsuccessful in Facebook Login
    else {
      return;
    }
  }

  Future<void> createOrSignInApple() async {
    // Perform the Apple login
    UserCredential? userCred = await _authService.appleLogin();

    // 1. User successfully logged into Apple and
    // has created or has an entry in FirebaseAuth
    if (userCred != null) {
      if (userCred.user != null) {
        // Extract the `uid` from the `UserCredential.User?`
        String uid = userCred.user!.uid;
        // Set up our [TagAlongUser] instance
        await setUpUser(uid, signInMethod: SignInMethod.APPLE);
      }
    }
    // 2. User unsuccessful in Apple Login
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
    if (uid.isEmpty) {
      logger.log.fine('setUpUser() - TagAlongUser uid is null');
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
      // as an "Unregistered TagAlongUser".
      else {
        logger.log.fine('setUpUser() - User did not exist!');
        final time = DateTime.now();

        if (signInMethod == SignInMethod.FACEBOOK) {
          // Get the User's Facebook profile picture
          Map<String, dynamic> json = await authService.getFacebookProfilePicture();
          String url = json['picture']?['data']?['url']; // Should always exist?
          tagAlongUser = TagAlongUser(
            id: uid,
            profilePictureUrl: url,
            createdAt: time,
            updatedAt: time,
          );
        } else {
          // Get the User's Facebook profile picture
          tagAlongUser = TagAlongUser(
            id: uid,
            profilePictureUrl: '',
            createdAt: time,
            updatedAt: time,
          );
        }
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
    } else {}
  }

  /// Updates our TagAlongUser instance's `driverData`
  void updateDriverAccountId(String accountId) {
    if (userExists()) {
      tagAlongUser!.stripeAccountId = accountId;
    } else {}
  }

  /// Adds a [TagAlongUser] to the Firestore `users` collection.
  Future<void> addTagAlongUserToFirestore(String uid) async {
    if (userExists()) {
      await databaseService.users.doc(uid).set(tagAlongUser!.toJson());
      logger.log.fine('addTagAlongUserToFirestore() - Added TagAlongUser $uid.');
    } else {
      logger.log
          .fine('addTagAlongUserToFirestore() - TagAlongUser instance does not exist in ViewModel; cannot happen');
    }
  }

  /// Updates this instance's [TagAlongUser] in-memory only
  void updateTagAlongUserInternal(Map<String, dynamic> data) {
    tagAlongUser?.updateTagAlongUser(data);
    logger.log.fine('updateTagAlongUserInternal() - TagAlongUser after update: ${tagAlongUser.toString()}');
    notifyListeners();
  }

  /// Updates the Firebase with this ViewModel's current instance of [user]
  ///
  /// Does not replace existing values
  Future<void> updateTagAlongUserFirestore() async {
    Map<String, dynamic> tagAlongUserData = tagAlongUser!.toJson();
    await _databaseService.users.doc(getUid()).update(tagAlongUserData);
    logger.log.fine('updateTagAlongUser(): jsonData - $tagAlongUserData');
  }

  Future<void> updateTagAlongUserAuth() async {
    Map<String, dynamic> tagAlongUserData = tagAlongUser!.toJson();
    await _authService.updateAuthUserName(tagAlongUserData['first_name'], tagAlongUserData['last_name']);
    logger.log.fine('updateTagAlongUserAuth(): jsonData - $tagAlongUserData');
  }

  /// Checks whether the current user is an 1. Active 2. Driver.
  bool isActiveDriver() {
    return tagAlongUser?.isActiveDriver() ?? false;
  }

  bool isStripeActive() {
    return tagAlongUser?.isStripeActive() ?? false;
  }

  bool isEmailVerified() {
    final user = getUser();
    if (user == null) {
      return false;
    }
    return user.emailVerified;
  }

  Future<TagAlongUser?> getUserFromID(String userId) async {
    try {
      final _userDocSnapshot = await databaseService.users.doc(userId).get();
      final _userData = _userDocSnapshot.data() as Map<String, dynamic>;
      final _userFormatted = TagAlongUser.fromJson(_userData);
      return _userFormatted;
    } catch (e) {
      logger.log.fine('Could not retrieve user : ${e.toString()}');
      rethrow;
    }
  }
}
