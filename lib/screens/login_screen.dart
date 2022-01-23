import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/util/log.dart' as logger;

// A Class for Facebook Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var logged_in = false;
  var registered = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // 3 main states when the user opens:
  //   // 1. User is NOT logged in (auth) AND NOT registered (custom)
  //   // 2. User is logged in AND NOT registered
  //   // 3. User is logged in AND registered
  //
  //   var auth_service = Provider.of<AuthService>(context, listen: false);
  //   auth_service.currentUser.listen((fb_user) {
  //
  //     // 1. User is NOT logged in
  //     if (fb_user == null) {
  //       print('DEBUG: TagAlong initState - User is LOGGED OUT');
  //       logged_in = false;
  //     }
  //     // 2. User is logged in
  //     else {
  //       print('DEBUG: TagAlong initState - User is LOGGED IN');
  //       logged_in = true;
  //     }
  //
  //     // get registration status
  //     registered = _is_registered();
  //
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var auth_service = Provider.of<AuthService>(context, listen: false);

    return _get_login_widget();
  }

  /*
  get_login_widget() returns the LoginScreen Widget
   */
  Widget _get_login_widget() {
    // Get an instance of our AuthService
    var auth_service = Provider.of<AuthService>(context);

    return Scaffold(
        body: SafeArea(
      child: Center(
          child: Column(children: [
        Expanded(
            child: Container(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              // Logo, "Tag Along", description
              Icon(Icons.directions_car_outlined, size: 75),
              Text("TagAlong", style: Theme.of(context).textTheme.headline1),
              Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Get a ride home for the holidays",
                    style: Theme.of(context).textTheme.bodyText2,
                  ))
            ]))),
        Expanded(
            child: Center(
                child: Container(
                    height: 50,
                    // Facebook Logo and Text
                    child: SignInButton(Buttons.FacebookNew, onPressed: () {
                      logger.log.fine('Logging in');
                      auth_service.facebook_login();
                      if (true) {}
                      // Navigator.pushNamed(context, '/register_user');
                    }))))
      ])),
    ));
  }

  /*
  register_or_home() will check `logged_in` state and return
  a "RideBoardScreen" widget if logged in, or "LoginScreen" else wise.
   */
  Widget _register_or_home() {
    logger.log.fine('in _register_or_home - current state is $logged_in');
    if (logged_in == true) {
      return RideBoardScreen();
    } else {
      return _get_login_widget();
    }
  }

  /* _is_registered() will ask Firebase to see if a user is registered */
  // TODO: Add async realtime functionality
  bool _is_registered() {
    logger.log.fine('is_registered: false');
    return false;
  }

  // A helper method for converting a Map reflecting JSON into a pretty string.
  String prettyPrint(Map json) {
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String pretty = encoder.convert(json);
    return pretty;
  }
}
