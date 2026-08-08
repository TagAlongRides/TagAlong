import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

/// [LoginScreen] will be a Screen Widget that either:
///
/// 1. Creates a new "TagAlong" User who is NOT registered.
/// 2. Signs in a existing "TagAlong" User who may or may-not be registered.
class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Blocks a second attempt while one provider's flow is open.
  bool _signingIn = false;

  /// Runs a provider's sign-in and routes on the result.
  ///
  /// All three providers land in the same place: if we end up with a
  /// TagAlongUser the registration wrapper decides where they go next,
  /// otherwise they stay here. A [SignInFailure] is shown to the user —
  /// notably when the address is already registered against a different
  /// provider, which is easy to hit once there is more than one button.
  Future<void> _signIn(String provider, Future<void> Function() attempt) async {
    logger.log.fine('login_screen - attempting to login via $provider');
    setState(() => _signingIn = true);

    try {
      await attempt();
    } on SignInFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), duration: const Duration(seconds: 5)),
      );
      return;
    } catch (error) {
      logger.log.fine('login_screen - $provider sign-in failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sorry, that sign-in did not work. Please try again.')),
      );
      return;
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }

    if (!mounted) return;

    final userViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    if (userViewModel.userExists()) {
      logger.log.fine('login_screen - User exists - go to /registration_wrapper');
      Navigator.pushReplacementNamed(context, RegistrationWrapper.routeName);
    } else {
      logger.log.fine('login_screen - User cannot sign-in - stay on /login_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
                flex: 4,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // 1. Logo
                  const Icon(Icons.directions_car_outlined, size: 75),

                  // 2. TagAlong Header
                  Text(
                    "TagAlong",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),

                  // 3. Description
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Get a ride home for the holidays",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ))
                ])),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: SignInButton(
                      Buttons.FacebookNew,
                      onPressed: _signingIn
                          ? () {}
                          : () => _signIn('Facebook', tagAlongUserViewModel.createOrSignIn),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 40,
                    child: SignInButton(
                      Buttons.Google,
                      onPressed: _signingIn
                          ? () {}
                          : () => _signIn('Google', tagAlongUserViewModel.createOrSignInGoogle),
                    ),
                  ),
                  if (Platform.isIOS) const SizedBox(height: 16.0),
                  if (Platform.isIOS)
                    SizedBox(
                      height: 40,
                      child: SignInButton(
                        Buttons.AppleDark,
                        onPressed: _signingIn
                            ? () {}
                            : () => _signIn('Apple', tagAlongUserViewModel.createOrSignInApple),
                      ),
                    ),
                  if (_signingIn)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
