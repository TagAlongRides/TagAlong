import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/screens/startup_authentication/login_screen.dart';
import 'package:tagalong/services/user_service.dart';
import 'package:tagalong/util/constants.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/register_user_view_model.dart';


class RegisterScreen extends StatefulWidget {

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // Form state
  final formKey = GlobalKey<FormState>();
  final emailAddress = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // state for password obfuscation
  bool _obscured = true;

  @override
  void dispose() {
    emailAddress.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RegisterUserViewModel vm = Provider.of<RegisterUserViewModel>(context, listen: false);
    UserService us = serviceLocator.get<UserService>();

    return Scaffold(
      body: SafeArea(
          child: Form(
            key: formKey,
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

                                      // User School Email
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                        child: TextFormField(
                                          controller: emailAddress,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                              ),
                                              labelText: 'Email',
                                              hintText: 'student@uni.edu',
                                              isDense: true
                                          ),
                                          validator: vm.validateAndUpdateEmail
                                        ),
                                      ),

                                      // Password
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                        child: TextFormField(
                                          controller: password,
                                          obscureText: true,
                                          decoration: const InputDecoration(
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
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                        child: TextFormField(
                                          controller: confirmPassword,
                                          validator: (String? tmp) {
                                            // Validate the two password TextFields - [tmp] doesn't really matter here
                                            return vm.validateAndUpdatePassword(password.text, confirmPassword.text);
                                          },
                                          obscureText: true,
                                          decoration: const InputDecoration(
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
                                          onPressed: () async {
                                            if (formKey.currentState!.validate()) {

                                              // Client-side validation passed - create user
                                              String errorCode = await us.createUserWithEmailAndPassword(
                                                  email: vm.emailAddress!,
                                                  password: vm.password!
                                              );

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
                                              else {
                                                Navigator.pop(context);
                                              }

                                            }
                                          },
                                          child: const Text("Sign Up"),
                                          style: const ButtonStyle(
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ),
                                    ]
                                )
                            ),

                            // Empty Space + Replacement button
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

            ),
          )
      ),
    );
  }
}
