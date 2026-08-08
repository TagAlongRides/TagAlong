import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tagalong/util/log.dart' as logger;

/// Raised when a sign-in fails in a way worth telling the user about, rather
/// than silently returning them to the landing page.
class SignInFailure implements Exception {
  SignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// [AuthService] is the main service for our Firebase authentication.
///
/// It will contain the API for creating, signing in, and out, Firebase users
/// within the FirebaseAuth system.
class AuthService with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _fb = FacebookAuth.instance;

  /// Returns a Stream<User?>, which notifies changes in a user's sign-in state.
  ///
  /// Note: It has an immediate event when first "listened" to about the
  /// current state of the user.
  Stream<User?> get userStatus => _auth.userChanges();

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

  /// Returns the signed-in user's Facebook account id, taken from their linked
  /// auth providers, or an empty string if they did not sign in with Facebook.
  ///
  /// This is what lets us deep-link to a driver's Facebook profile from the
  /// Ride Details page.
  String getFacebookId() {
    final user = _auth.currentUser;
    if (user == null) {
      return '';
    }
    for (final provider in user.providerData) {
      if (provider.providerId == 'facebook.com') {
        return provider.uid ?? '';
      }
    }
    return '';
  }

  Future<void> reloadUser() async {
    final user = await getUser()?.reload();
    notifyListeners();
    return;
  }

  /// Returns a Future<UserCredential?> that if the Facebook login is
  /// successful, will create a user within the FirebaseAuth system and return
  /// a UserCredential. If login fails, returns null.
  Future<UserCredential?> facebookLogin() async {
    final LoginResult result = await _fb.login();

    // Log-in was successful
    if (result.status == LoginStatus.success && result.accessToken != null) {
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      try {
        UserCredential? userCred = await _auth.signInWithCredential(facebookAuthCredential);
        return userCred;
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

  /// google_sign_in 7 requires an explicit one-off initialize before any
  /// authenticate call. On Android the client id comes from
  /// google-services.json, so no arguments are needed.
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleInitialized = true;
  }

  /// Returns a Future<UserCredential?> that if the Google login is successful,
  /// will create a user within the FirebaseAuth system and return a
  /// UserCredential. Returns null if the user backs out of the picker.
  ///
  /// Throws [SignInFailure] when the attempt fails for a reason the user needs
  /// to know about — most importantly when the address is already registered
  /// against a different provider.
  Future<UserCredential?> googleLogin() async {
    try {
      await _ensureGoogleInitialized();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw SignInFailure('Google sign-in is not available on this device.');
      }

      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        throw SignInFailure('Google did not return a usable sign-in token. Please try again.');
      }

      // Firebase accepts the ID token on its own; google_sign_in 7 no longer
      // hands back an access token from the authentication step.
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // Backing out of the account picker is not an error worth surfacing.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        logger.log.fine('DEBUG: Google sign-in cancelled by user');
        return null;
      }
      logger.log.fine('DEBUG: Google sign-in failed - ${e.code}: ${e.description}');
      throw SignInFailure('Google sign-in failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      logger.log.fine('DEBUG: User could NOT log-in due to ${e.message}');
      if (e.code == 'account-exists-with-different-credential') {
        throw SignInFailure(
            'That email is already registered with a different sign-in method. '
            'Please sign in the way you did originally.');
      }
      throw SignInFailure('Google sign-in failed. Please try again.');
    }
  }

  /// Returns a Future<UserCredential?> that if the Apple login is
  /// successful, will create a user within the FirebaseAuth system and return
  /// a UserCredential. If login fails, returns null.
  Future<UserCredential?> appleLogin() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        // rawNonce: rawNonce,
      );

      UserCredential? userCred = await _auth.signInWithCredential(oauthCredential);
      return userCred;
    } catch (error) {
      return null;
    }

    // final LoginResult result = await _fb.login();

    // // Log-in was successful
    // if (result.status == LoginStatus.success && result.accessToken != null) {
    //   final OAuthCredential facebookAuthCredential =
    //       FacebookAuthProvider.credential(result.accessToken!.tokenString);
    //   try {
    //     UserCredential? user_cred =
    //         await _auth.signInWithCredential(facebookAuthCredential);
    //     return user_cred;
    //   }
    //   // Log-in failed
    //   on FirebaseAuthException catch (e) {
    //     logger.log.fine('DEBUG: User could NOT log-in due to ${e.message}');
    //     return null;
    //   }
    // }
    // // Log-in failed
    // else {
    //   logger.log.fine('DEBUG: User could NOT log-in!');
    //   return null;
    // }
  }

  /// Returns a Future<UserCredential?> that if the Facebook login is
  /// successful, will create a user within the FirebaseAuth system and return
  /// a UserCredential. If login fails, returns null.

  /// Queries for the User's Facebook Profile picture and returns
  /// the JSON GraphAPI result.
  Future<Map<String, dynamic>> getFacebookProfilePicture() async {
    logger.log.fine('Querying for user\'s Profile picture');
    Map<String, dynamic> json = await _fb.getUserData(fields: "picture.width(200)");
    return json;
  }

  /// The provider the current user signed in with, as Firebase records it
  /// (`facebook.com`, `google.com`, `apple.com`), or null if unknown.
  String? currentProviderId() {
    final providers = _auth.currentUser?.providerData;
    if (providers == null || providers.isEmpty) {
      return null;
    }
    return providers.first.providerId;
  }

  /// Re-authenticates the current user with whichever provider they signed in
  /// with.
  ///
  /// Needed before sensitive changes such as swapping the account's email.
  /// Previously this always built a Facebook credential, which threw for
  /// anyone who had signed in another way.
  Future<void> reauthenticate() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw SignInFailure('You are not signed in.');
    }

    switch (currentProviderId()) {
      case 'facebook.com':
        final authToken = await _fb.accessToken;
        if (authToken == null) {
          throw SignInFailure('Please sign in with Facebook again to continue.');
        }
        await user.reauthenticateWithCredential(
          FacebookAuthProvider.credential(authToken.tokenString),
        );
        return;

      case 'google.com':
        await _ensureGoogleInitialized();
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          throw SignInFailure('Please sign in with Google again to continue.');
        }
        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
        return;

      case 'apple.com':
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email],
        );
        await user.reauthenticateWithCredential(
          OAuthProvider('apple.com').credential(idToken: credential.identityToken),
        );
        return;

      default:
        throw SignInFailure('Please sign in again to continue.');
    }
  }

  /// Sign-out of TagAlong.
  Future<void> signOut() async {
    // Clear the Google session too, otherwise the next sign-in silently reuses
    // the previous account instead of showing the picker.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      logger.log.fine('Google sign-out skipped: $error');
    }
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> updateAuthUserName(String? firstName, String? lastName) async {
    try {
      final user = getUser();
      if (user == null) {
        logger.log.fine('Can' 't update auth name: No auth user logged in');
        return;
      }
      if (firstName == null || lastName == null) {
        logger.log.fine('Can' 't update auth name: New name not passed');
        return;
      }

      final newName = firstName + ' ' + lastName;
      if (user.displayName == newName) {
        logger.log.fine('No updated needed, auth user name already matches: ${user.displayName}');
        return;
      }
      return await user.updateDisplayName(newName);
    } catch (e) {
      logger.log.fine('Failed to update auth user name: ${e.toString()}');
    }
  }
}
