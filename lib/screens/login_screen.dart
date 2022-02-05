
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

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
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    "Get a ride home for the holidays",
                                    style: Theme.of(context).textTheme.bodyText2,
                                  )
                              )
                            ]
                        )
                    ),
                    Expanded(
                        child: Center(
                            child: SizedBox (
                                height: 40,
                                // Facebook Logo and Text
                                child: SignInButton(
                                    Buttons.FacebookNew,
                                    onPressed: () async {
                                      logger.log.fine('login_screen - attempting to login via Facebook');
                                      // the TagAlongUser can either sign-in (if they exist) or create a new
                                      // account (if they don't exist)
                                      await tagAlongUserViewModel.createOrSignIn();
                                      bool userExists = tagAlongUserViewModel.userExists();
                                      if (userExists == true) {
                                        logger.log.fine('login_screen - User exists - go to /registration_wrapper');
                                        Navigator.pushReplacementNamed(context, '/registration_wrapper');
                                      }
                                      else {
                                        logger.log.fine('login_screen - User cannot sign-in - stay on /login_screen');
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


