import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/widgets/driver_registration.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({Key? key}) : super(key: key);

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
            actions: [
              // TODO: STRICTLY DEBUGGING - NEED TO TAKE OUT
              OutlinedButton(
                  child: Text('Sign Out'),
                  onPressed: (() {
                    auth_service.signOut();
                  })
              )
            ],
            title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height:16),
                  Text(
                      'Start Driving',
                      style: TextStyle(fontSize: 24.0)
                  ),
                  Text(
                      'Tell us about your car!',
                      style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic
                      )
                  ),
                ]
            )
        ),
        body: const SafeArea(
          child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: DriverRegistrationForm(),
              )
          ),
        )
    );
  }
}
