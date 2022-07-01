import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:tagalong/util/log.dart' as logger;

/// [AuthService] is the main service for our Firebase authentication.
///
/// It will contain the API for creating, signing in, and out, Firebase users
/// within the FirebaseAuth system.
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _fb = FacebookAuth.instance;

  /// Returns a Stream<User?>, which notifies changes in a user's sign-in state.
  ///
  /// Note: It has an immediate event when first "listened" to about the
  /// current state of the user.
  Stream<User?> get userStatus => _auth.authStateChanges();

  /// Returns a unique String UID for a FirebaseAuth user OR null if
  /// [user] doesn't exist or somehow [uid] does not exist for [user].
  String? getUid() {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  /// Return the current [User] if signed-in, or null if not.
  User? getUser() {
    return _auth.currentUser;
  }

  /// Returns a Future<UserCredential?> that if the Facebook login is
  /// successful, will create a user within the FirebaseAuth system and return
  /// a UserCredential. If login fails, returns null.
  Future<UserCredential?> facebookLogin() async {
    final LoginResult result = await _fb.login();

    // Log-in was successful
    if (result.status == LoginStatus.success && result.accessToken != null) {
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      try {
        UserCredential? user_cred =
            await _auth.signInWithCredential(facebookAuthCredential);
        return user_cred;
      }
      // Log-in failed
      on FirebaseAuthException catch (e) {
        logger.log.fine('DEBUG: User could NOT log-in due to ${e.message}');
        return null;
      }
    }
    // Log-in failed
    else {
      logger.log.fine('DEBUG: User could NOT log-in!');
      return null;
    }
  }

  /// Returns a Future<UserCredential?> that if the Facebook login is
  /// successful, will create a user within the FirebaseAuth system and return
  /// a UserCredential. If login fails, returns null.
  Future<UserCredential?> appleLogin() async {
    final provider = OAuthProvider("apple.com")
      ..addScope('email')
      ..addScope('name');

    // Sign in the user with Firebase.
    var userCreds = await FirebaseAuth.instance.signInWithPopup(provider);
    // UserModel user = UserModel();

    // //Creating user first and last name
    // String userDisplayName = userCreds.user!.displayName!;
    // List<String> userFirstLastNameList =
    //     userCreds.user!.displayName!.split(" ").toList();

    // user.firstName = userFirstLastNameList[0];
    // user.lastName = userFirstLastNameList.last;
    // user.email = userCreds.user!.email;
    // user.imageUrl = userCreds.user!.photoURL;
    // user.userId = userCreds.user!.uid;

    // else {
    //   queryResult.docs[0].reference.set(user.toJson());
    // }

    //*****************Saved user to local */

    ///
  }

  /// Queries for the User's Facebook Profile picture and returns
  /// the JSON GraphAPI result.
  Future<Map<String, dynamic>> getFacebookProfilePicture() async {
    logger.log.fine('Querying for user\'s Profile picture');
    Map<String, dynamic> json =
        await _fb.getUserData(fields: "picture.width(200)");
    return json;
  }

  /// Sign-out of TagAlong.
  Future<void> signOut() => _auth.signOut();
}
