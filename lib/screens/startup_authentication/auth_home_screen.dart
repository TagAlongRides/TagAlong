import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/screens/startup_authentication/login_screen.dart';
import 'package:tagalong/services/user_service.dart';
import 'package:tagalong/util/constants.dart';
import 'package:tagalong/viewmodels/register_user_view_model.dart';

class AuthHomeScreen extends StatelessWidget {
  const AuthHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ViewModel for holding Form data - name, year, email, etc..
    RegisterUserViewModel vm = Provider.of<RegisterUserViewModel>(context, listen: false);

    // UserService singleton
    UserService us = serviceLocator.get<UserService>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //  Logo
                    const Icon(Icons.directions_car_outlined, size: 75),

                    // Description
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "TagAlong",
                        style: Theme.of(context).textTheme.headline2,
                      )
                    )
                  ]
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: SignInButton(
                          Buttons.Email,
                          text: "Continue with Email",
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen())
                            );
                          }
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: SignInButton(
                          Buttons.FacebookNew,
                          text: "Continue with Facebook",
                          onPressed: () async {

                            // Sign in OR create Firebase User
                            String errorCode = await us.signInWithFacebook();

                            // Check [errorCode] and present:
                            // - AlertDialog on error and stay OR
                            // - pop() off [RegisterScreen] back to AuthGate
                            if (errorCode != Constants.FIREBASE_AUTH_SUCESS) {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: const Text("Account Creation Error"),
                                        content: Text("$errorCode\nTry again."),
                                        actions: [
                                          TextButton(
                                            child: const Text("OK"),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          )
                                        ]
                                    );
                                  });
                            }
                          }
                      ),
                    ),
                    if (Platform.isIOS)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: SignInButton(
                          Buttons.AppleDark,
                          text: "Continue with Apple",
                          onPressed: () {
                          },
                        ),
                      )
                  ]
                )
              )
            ]
          ),
        )
      )
    );
  }
}
