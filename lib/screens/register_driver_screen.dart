import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/widgets/driver_registration_form.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({Key? key}) : super(key: key);
  static const routeName = '/register_driver';

  @override
  _RegisterDriverScreenState createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            toolbarHeight: 100,
            // Driver registration is optional, so there is always a way out of
            // it. This screen is reached by pushReplacement from the prompt,
            // which leaves no route to pop back to, so without this a driver
            // whose car details fail to load has nowhere to go.
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false),
                child: Text(
                  'Not now',
                  style: TextStyle(color: TagAlongTheme.secondarySwatch.shade50),
                ),
              ),
            ],
            title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 16),
                  Text('Start Driving', style: TextStyle(fontSize: 24.0)),
                  Text('Tell us about your car!', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                ])),
        body: const Center(
            child: Padding(
          padding: EdgeInsets.all(40.0),
          child: DriverRegistrationForm(),
        )));
  }
}
