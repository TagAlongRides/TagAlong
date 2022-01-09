import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/*
This class will be the main Model/service for our Firebase authentication
and login functionality with Facebook provider.
 */
class AuthService {
  // Our private instance of the Firebase Authentication SDK
  final _auth = FirebaseAuth.instance;
  // Our private instance of the Facebook Authentication SDK
  final _fb = FacebookAuth.instance;
  // An instance of a User if logged in
  late final UserCredential user_cred;

  // 1. Monitor Authentication state of our user (logged in, logged out, etc.)
  // `currentUser` is a Stream<User?> that notifies changes about sign-in state.
  Stream<User?> get currentUser => _auth.authStateChanges();

  // 2. Sign in with Facebook Credential.
  // asynchronously sign in to Firebase with 3rd-party tokens.
  // If successful, signs user in, notifies via `authStateChanges` and will
  // create a Firebase account if one does not exist.
  Future<UserCredential?> facebook_login() async {
    // Attempt log in to Facebook (native window pop up) - asynchronous
    final LoginResult result = await _fb.login();

    // Log-in was successful
    if (result.status == LoginStatus.success) {
      final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);
      print('DEBUG: Logging in to Facebook!');
      user_cred = await _auth.signInWithCredential(facebookAuthCredential);
      return user_cred;
    }
    // Log-in failed
    else {
      print('ERROR: Log in failed!');
    }
  }

  // 3. Sign out of Facebook, hence Firebase
  Future<void> sign_out() => _auth.signOut();
}