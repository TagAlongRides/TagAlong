import 'package:flutter/material.dart';
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
                          flex: 1 ,
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
                      const Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(1.0),
                            child: Text(""),
                          )
                      ),
                    ]
                  )
                )
              ]

            )
        ),
    );
  }
}
