import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/startup_authentication/reg_name_screen.dart';
import 'package:tagalong/viewmodels/register_user_view_model.dart';
import 'package:tagalong/widgets/ui_helpers/text_divider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegisterUserViewModel vm = Provider.of<RegisterUserViewModel>(context, listen: false);

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
                      ]
                    )
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: TextDivider(middleText: "Sign Up With")
                        ),
                        const SizedBox(height:16),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: SignInButton(
                            Buttons.FacebookNew,
                            text: "Sign up with Facebook",
                            onPressed: () {
                              // SignUpMethod == Facebook
                              vm.signUpMethod = "Facebook";
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegNameScreen())
                              );
                            }
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: SignInButton(
                            Buttons.Email,
                            text: "Sign up with School Email",
                            onPressed: () {
                              // SignUpMethod == Email
                              vm.signUpMethod = "Email";
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const RegNameScreen())
                              );
                            }
                          ),
                        ),
                        if (Platform.isIOS)
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: SignInButton(
                            Buttons.AppleDark,
                            text: "Sign up with Apple",
                            onPressed: () {
                              // SignUpMethod == Apple
                              vm.signUpMethod = "Apple";
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegNameScreen())
                              );
                            },
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
      )
    );
  }
}
