import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "TagAlong",
                        style: Theme.of(context).textTheme.headline4,
                      )
                    )
                  ]
                )
              ),
              Expanded(
                flex: 1,
                child: Text("adf")
              )
            ]
          ),
        )
      )
    );
  }
}
