import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email TextField Widgets
                Flexible(
                  fit: FlexFit.loose,
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Welcome,\nGlad to see you",
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
                    ]
                  )
                ),

                // SSO Widgets (FB & Apple)
                const Flexible(
                  fit: FlexFit.loose,
                  flex: 1,
                  child: Text("adf")
                ),
                const Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Text("adf")
                )
              ]
            ),
          ),

      )
    );
  }
}
