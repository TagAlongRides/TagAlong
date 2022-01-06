import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/*
This class will be the main Model/service for our Firebase authentication
and login functionality with Facebook provider.
 */
class AuthService {
  // Our private instance of the Firebase Authentication SDK
  final _auth = FirebaseAuth.instance;
  //
  final _fb = FacebookAuth.instance;

  // 1. Monitor Authentication state of our user (logged in, logged out, etc.)
  // `currentUser` is a Stream<User?> that notifies changes about sign-in state.
  Stream<User?> get currentUser => _auth.authStateChanges();

  // 2. Sign in with Facebook Credential.
  // asynchronously sign in to Firebase with 3rd-party tokens.
  // If successful, signs user in, notifies via `authStateChanges` and will
  // create a Firebase account if one does not exist.
  // Future<UserCredential> sign_in_with_credential(AuthCredential credential) {
  //   return _auth.signInWithCredential(credential);
  // }

  Future<UserCredential?> facebook_login() async {
    final LoginResult result = await _fb.login();   // pop-up window to Facebook
    if (result.status == LoginStatus.success) {
      final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);
      return _auth.signInWithCredential(facebookAuthCredential);
    }
    else {
      print('ERROR: Log in failed!');
    }
  }

  // 3. Sign out of Facebook, hence Firebase
  Future<void> sign_out() => _auth.signOut();
}