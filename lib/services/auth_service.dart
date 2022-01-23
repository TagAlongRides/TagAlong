import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// [AuthService] is the main service for our Firebase authentication.
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
    }
    else {
      return null;
    }
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
        UserCredential? user_cred = await _auth.signInWithCredential(facebookAuthCredential);
        return user_cred;
      }
      // Log-in failed
      on FirebaseAuthException catch (e) {
        print('DEBUG: User could NOT log-in due to ${e.message}');
        return null;
      }
    }
    // Log-in failed
    else {
      print('DEBUG: User could NOT log-in!');
    }
  }


  /// Sign-out of TagAlong.
  Future<void> signOut() => _auth.signOut();
}