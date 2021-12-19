import 'package:flutter/material.dart';

// A Class for Facebook Login
class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center (
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo, "Tag Along", description
                    Icon(
                        Icons.directions_car_outlined,
                        size: 75
                    ),
                    Text(
                        "Tag Along",
                        style: Theme.of(context).textTheme.headline1
                    ),
                    Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Get a ride home for the holidays",
                          style: Theme.of(context).textTheme.bodyText2
                      )
                    )
                  ]
                )
              )
            ),
            Expanded(
              child: Container(

              )
            )
          ]
        )
      )
    );
  }
}
// Center(
// child: Column(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// // Top half for image, "Tag Along", and Description
// Container(
// color: Colors.red,
// ),
// // Bottom-half for Facebook Login button
// Container(
// color: Colors.blue,
// )
// ]
// )
// )
