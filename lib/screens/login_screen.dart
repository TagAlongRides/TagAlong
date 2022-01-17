import 'dart:convert';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/services/auth_service.dart';

/// [LoginScreen] will be a Screen Widget that allows a signed-out FirebaseAuth
/// User log in via Facebook, all through [AuthService].
class LoginScreen extends StatefulWidget {
  const  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    // Obtain a reference to AuthService
    AuthService _authService = Provider.of<AuthService>(context, listen: false);

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
                                      UserCredential? userCred = await _authService.facebookLogin();
                                      if (userCred != null) {
                                        Navigator.pushReplacementNamed(context, '/registration_wrapper');
                                      }
                                      else{

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

