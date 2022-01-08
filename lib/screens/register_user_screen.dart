import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {

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
            SizedBox(height:16),
            Text(
              'School Information',
              style: TextStyle(fontSize: 24.0)
            ),
            Text(
              'Nice to meet you!',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic
              )
            ),
          ]
        )
      ),
      body: Center(
        // TODO: STRICTLY DEBUGGING - NEED TO TAKE OUT
        child: OutlinedButton(
          child: Text('Sign Out'),
          onPressed: (() {
            auth_service.sign_out();
          })
        )
      )
    );
  }
}
