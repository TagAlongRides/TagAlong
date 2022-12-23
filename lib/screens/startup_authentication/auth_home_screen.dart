import 'package:flutter/material.dart';

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
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {},
                            child: const Text('Log In')
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: const ButtonStyle(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {},
                              child: const Text('Sign Up')
                          )
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
