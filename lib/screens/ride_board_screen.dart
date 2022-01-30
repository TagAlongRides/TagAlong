import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';

class RideBoardScreen extends StatefulWidget {
  const RideBoardScreen({Key? key}) : super(key: key);

  @override
  _RideBoardScreenState createState() => _RideBoardScreenState();
}

class _RideBoardScreenState extends State<RideBoardScreen> {

  @override
  Widget build(BuildContext context) {
    AuthService authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rideboard'),
        actions: [
          ElevatedButton(
              onPressed: () {
                authService.signOut();
              },
              child: const Text('Sign Out')
          )
        ]
      ),
      body: const Center(
        child: Text("Ride Board")
      )
    );
  }
}
