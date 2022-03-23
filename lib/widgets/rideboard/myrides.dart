import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import '../../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

class MyRides extends StatefulWidget {
  const MyRides({Key? key}) : super(key: key);

  @override
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  @override
  Widget build(BuildContext context) {
    logger.log.fine('MyRides Build');
    return const Text('My Rides');
  }
}
