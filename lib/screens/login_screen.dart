import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

/// [LoginScreen] will be a Screen Widget that either:
///
/// 1. Creates a new "TagAlong" User who is NOT registered.
/// 2. Signs in a existing "TagAlong" User who may or may-not be registered.
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login_screen';

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top:64.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //  Logo
                        const Icon(Icons.directions_car_outlined, size: 75),

                        // // TagAlong Header
                        // Text(
                        //   "TagAlong",
                        //   style: Theme.of(context).textTheme.headline2,
                        // ),

                        // Description
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Log In To TagAlong",
                              style: Theme.of(context).textTheme.bodyText1,
                            )
                        )
                      ]
                    ),
                  )
              ),

              // List of sign-in options
              Expanded(
                flex: 3,
                child: Column(
                  children: [

                    // Email Sign-in
                    const Padding(
                      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'student@vt.edu',
                          isDense: true
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'student@vt.edu',
                          isDense: true
                        ),
                      ),
                    ),

                    // Facebook Sign-in
                    Padding(
                      padding: const EdgeInsets.only(top:16.0),
                      child: SignInButton(
                        Buttons.FacebookNew,
                        onPressed: () async {
                          logger.log.fine('login_screen - attempting to login via Facebook');
                          // the TagAlongUser can either sign-in (if they exist) or create a new
                          // account (if they don't exist).
                          await tagAlongUserViewModel.createOrSignIn();
                          bool userExists = tagAlongUserViewModel.userExists();
                          if (userExists == true) {
                            logger.log.fine('login_screen - User exists - go to /registration_wrapper');
                            Navigator.pushReplacementNamed(context, RegistrationWrapper.routeName);
                          } else {
                            logger.log.fine('login_screen - User cannot sign-in - stay on /login_screen');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (Platform.isIOS)
                      SignInButton(
                        Buttons.AppleDark,
                        onPressed: () async {
                          logger.log.fine('login_screen - attempting to login via Apple');
                          // the TagAlongUser can either sign-in (if they exist) or create a new
                          // account (if they don't exist).
                          await tagAlongUserViewModel.createOrSignInApple();
                          bool userExists = tagAlongUserViewModel.userExists();
                          if (userExists == true) {
                            logger.log.fine('login_screen - User exists - go to /registration_wrapper');
                            Navigator.pushReplacementNamed(context, RegistrationWrapper.routeName);
                          } else {
                            logger.log.fine('login_screen - User cannot sign-in - stay on /login_screen');
                          }
                        },
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
