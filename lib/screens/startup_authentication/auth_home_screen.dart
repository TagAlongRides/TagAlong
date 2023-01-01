import 'package:flutter/material.dart';
import 'package:tagalong/screens/startup_authentication/login_screen.dart';
import 'package:tagalong/screens/startup_authentication/register_screen.dart';

class AuthHomeScreen extends StatelessWidget {
  const AuthHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen())
                          );
                        },
                        child: const Text('Log In')
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen())
                          );
                        },
                        child: const Text('Sign Up')
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
