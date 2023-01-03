import 'package:flutter/material.dart';
import 'package:tagalong/screens/startup_authentication/register_screen.dart';
import 'package:tagalong/util/log.dart' as logger;


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                        "Welcome,\nGlad to see you!",
                                        style: Theme.of(context).textTheme.headline4,
                                        textAlign: TextAlign.center
                                    )
                                ),
                                // Email Sign-in
                                const Padding(
                                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                                  child: TextField(
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        labelText: 'Email',
                                        hintText: 'student@uni.edu',
                                        isDense: true
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                                  child: TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        labelText: 'Password',
                                        isDense: true
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: TextButton(
                                      style: const ButtonStyle(
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        logger.log.fine('TODO - Forgot Password button');
                                      },
                                      child: const Text('Forgot Password?'),
                                    ),
                                  ),
                                )
                              ]
                          )
                      ),

                      // SSO Widgets (FB & Apple)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Sign In"),
                                  style: const ButtonStyle(
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              child: TextButton(
                                style: const ButtonStyle(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen())
                                  );
                                },
                                child: const Text('Don\'t have an account? Sign Up Now.')
                              ),
                            )
                          ]
                        )
                      )
                    ]
                  )
                )
              ]

            )
        ),
    );
  }
}
