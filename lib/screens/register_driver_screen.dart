import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
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
    var auth_service = Provider.of<AuthService>(context);

    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            toolbarHeight: 100,
            title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 16),
                  Text('Start Driving', style: TextStyle(fontSize: 24.0)),
                  Text('Tell us about your car!', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                ])),
        body: Center(
            child: Padding(
          padding: EdgeInsets.all(40.0),
          child: DriverRegistrationForm(),
        )));
  }
}
