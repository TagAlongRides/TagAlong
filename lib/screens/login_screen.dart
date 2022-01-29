import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

/// [LoginScreen] will be a Screen Widget that either:
///
/// 1. Creates a new "TagAlong" User who is NOT registered.
/// 2. Signs in a existing "TagAlong" User who may or may-not be registered.
class LoginScreen extends StatelessWidget {
  const  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    return Scaffold(
        body: SafeArea(
          child: Center (
              child: Column(
                  children: [
                    Expanded(
                        child: Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo, "Tag Along", description
                                  const Icon(
                                      Icons.directions_car_outlined,
                                      size: 75
                                  ),
                                  Text(
                                      "TagAlong",
                                      style: Theme.of(context).textTheme.headline1
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        "Get a ride home for the holidays",
                                        style: Theme.of(context).textTheme.bodyText2,
                                      )
                                  )
                                ]
                            )
                        )
                    ),
                    Expanded(
                        child: Center(
                            child: Container (
                                height: 40,
                                // Facebook Logo and Text
                                child: SignInButton(
                                    Buttons.FacebookNew,
                                    onPressed: () async {
                                      print('DEBUG: login_screen - attempting to login via Facebook');
                                      // the TagAlongUser can either sign-in (if they exist) or create a new
                                      // account (if they don't exist)
                                      await tagAlongUserViewModel.createOrSignIn();
                                      bool userExists = tagAlongUserViewModel.userExists();
                                      if (userExists == true) {
                                        print('DEBUG: User exists - go to /registration_wrapper');
                                        Navigator.pushReplacementNamed(context, '/registration_wrapper');
                                      }
                                      else {
                                        print('DEBUG: User does NOT exist - stay on /login_screen');
                                      }
                                    }
                                )
                            )
                        )
                    )
                  ]
              )
          ),
        )
    );
  }
}


