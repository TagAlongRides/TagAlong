import 'package:flutter/material.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';

class DriverRegistrationPromptScreen extends StatelessWidget {
  const DriverRegistrationPromptScreen({Key? key}) : super(key: key);
  static const routeName = '/driver_registration_prompt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('TagAlong')),
        body: Column(children: [
          Expanded(
              flex: 5,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Padding(padding: EdgeInsets.all(12.0), child: Text('Would you like to register as a TagAlong Driver?')),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Becoming a driver allows you to posts rides to & from'
                      ' your desired locations comfortably, all while earning a few '
                      'bucks along the way!'),
                )
              ])),
          Expanded(
              flex: 2,
              child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, RegisterDriverScreen.routeName);
                  },
                  child: const Text('Sure'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, RideBoardScreen.routeName);
                  },
                  child: const Text('Skip driver registration for now'),
                )
              ])))
        ]));
  }
}
