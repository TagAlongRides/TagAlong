import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

/// [LoginScreen] will be a Screen Widget that either:
///
/// 1. Creates a new "TagAlong" User who is NOT registered.
/// 2. Signs in a existing "TagAlong" User who may or may-not be registered.
class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StripeConnectResponse? _connectResponse;

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel =
        Provider.of<TagAlongUserViewModel>(context, listen: false);

    return Scaffold(
        body: Center(
            child: Column(children: [
      Expanded(
          flex: 4,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // 1. Logo
            const Icon(Icons.directions_car_outlined, size: 75),

            // 2. TagAlong Header
            Text(
              "TagAlong",
              style: Theme.of(context).textTheme.headline2,
            ),

            // 3. Description
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Get a ride home for the holidays",
                  style: Theme.of(context).textTheme.bodyText2,
                ))
          ])),
      Expanded(
          flex: 2,
          child: Column(children: [
            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/stripe-registration')
                      .then((value) {
                    if (value != null) {
                      setState(() {
                        _connectResponse = value as StripeConnectResponse;
                      });
                    }
                  });
                },
                icon: _connectResponse == null
                    ? const Icon(Icons.payment_rounded)
                    : const Icon(Icons.check_rounded),
                label: const Text('Connect To Stripe'),
                style: ElevatedButton.styleFrom(
                  primary: _connectResponse == null
                      ? Colors.red.withOpacity(.9)
                      : Colors.green.withOpacity(.9),
                ),
              ),
            ),
            // ElevatedButton.icon(
            //   onPressed: () {},
            //   icon: ,
            //   child: const Text('Connect To Stripe'),
            //   style: ElevatedButton.styleFrom(primary: Colors.red),
            // ),
            SizedBox(
                height: 40,
                // Facebook Logo and Text
                child: SignInButton(Buttons.FacebookNew, onPressed: () async {
                  logger.log
                      .fine('login_screen - attempting to login via Facebook');
                  // the TagAlongUser can either sign-in (if they exist) or create a new
                  // account (if they don't exist).
                  await tagAlongUserViewModel.createOrSignIn();
                  bool userExists = tagAlongUserViewModel.userExists();
                  if (userExists == true) {
                    logger.log.fine(
                        'login_screen - User exists - go to /registration_wrapper');
                    Navigator.pushReplacementNamed(
                        context, '/registration_wrapper');
                  } else {
                    logger.log.fine(
                        'login_screen - User cannot sign-in - stay on /login_screen');
                  }
                })),
            const SizedBox(height: 16.0),
            SizedBox(
                height: 40,
                // Facebook Logo and Text
                child: SignInButton(Buttons.AppleDark, onPressed: () {
                  logger.log.fine('Apple Sign-in TODO');
                }))
          ]))
    ])));
  }
}
