import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// A Class for Facebook Login
class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center (
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo, "Tag Along", description
                      Icon(
                          Icons.directions_car_outlined,
                          size: 75
                      ),
                      Text(
                          "Tag Along",
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
                    height: 50,
                    // Facebook Logo and Text
                    child: SignInButton(
                      Buttons.FacebookNew,
                      onPressed: () async {
                        final LoginResult result = await FacebookAuth.instance.login(
                            loginBehavior: LoginBehavior.nativeOnly); // by default we request the email and the public profile
                        if (result.status == LoginStatus.success) {
                          // you are logged
                          print('Logged in!');
                          print('User data:');
                          final userData = await FacebookAuth.instance.getUserData();
                          print(prettyPrint(userData));
                          final AccessToken accessToken = result.accessToken!;
                        } else {
                          print(result.status);
                          print(result.message);

                        }
                      }
                    )
                  )
                )
              )
            ]
          )
        )
      ),
    );
  }

  // A helper method for converting a Map reflecting JSON into a pretty string.
  String prettyPrint(Map json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }

  /*
  Will asynchronously send a "login" request through the use of `FacebookAuth`
  and the Facebook SDK to attempt to login a user.
  Will return a Future<LoginResult> which contains the status and accessToken
   */
  void get_login_result() async {

    // Get Facebook Login Result
    final LoginResult result = await FacebookAuth.instance.login(
        loginBehavior: LoginBehavior.nativeOnly); // by default we request the email and the public profile

    // Best Case - you are authenticated; save accessToken and continue
    if (result.status == LoginStatus.success) {
      // you are logged
      print('Logged in!');
      print('User data:');
      final userData = await FacebookAuth.instance.getUserData();
      print(prettyPrint(userData));
      final AccessToken accessToken = result.accessToken!;
    }
    // Worst Case - authentication errors out (wrong auth, no internet, etc..)
    else {
      print(result.status);
      print(result.message);
    }
  }

}

