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
                    Icon(Icons.directions_car_outlined),
                    Text("Tag Along"),
                    Text("Get a ride home for the holidays")
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
