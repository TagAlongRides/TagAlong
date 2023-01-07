import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:tagalong/widgets/ui_helpers/text_divider.dart';

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              "Create Account\nto get started now!",
                              style: Theme.of(context).textTheme.headline4,
                              textAlign: TextAlign.center
                          )
                        ),
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
                          padding: const EdgeInsets.only(left:16, right: 16, top: 32),
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

                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: TextDivider(middleText: "Or Sign Up With")
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SignInButton(
                                Buttons.Facebook,
                                mini: true,
                                onPressed: () {}
                              ),
                            if (Platform.isIOS)
                              SignInButton(
                                Buttons.AppleDark,
                                mini: true,
                                onPressed: () {},
                              )
                            ]
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}
