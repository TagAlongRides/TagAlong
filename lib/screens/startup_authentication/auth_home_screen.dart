import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/screens/startup_authentication/login_screen.dart';
import 'package:tagalong/services/user_service.dart';
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
                          onPressed: () {

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
