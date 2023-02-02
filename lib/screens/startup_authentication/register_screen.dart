import 'package:flutter/material.dart';
import 'package:tagalong/screens/startup_authentication/login_screen.dart';
import 'package:tagalong/util/log.dart' as logger;


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

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
                              flex: 2,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                            "Create Account\nto get started!",
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
                                            labelText: 'Confirm Password',
                                            isDense: true
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left:16,right:16,top:32),
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: const Text("Sign Up"),
                                        style: const ButtonStyle(
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                    ),
                                  ]
                              )
                          ),

                          // SSO Widgets (FB & Apple)
                          Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 32),
                                      child: TextButton(
                                          style: const ButtonStyle(
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => const LoginScreen())
                                            );
                                          },
                                          child: const Text('Already have an account? Sign In Now.')
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
