import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import '../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

class RideBoardScreen extends StatefulWidget {
  const RideBoardScreen({Key? key}) : super(key: key);

  @override
  _RideBoardScreenState createState() => _RideBoardScreenState();
}

class _RideBoardScreenState extends State<RideBoardScreen> {

  @override
  Widget build(BuildContext context) {
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    logger.log.fine('In Ride Board!');
    logger.log.fine('${tagAlongUserViewModel.tagAlongUser?.toMap()}');

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
