import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import '../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

class RideBoardList extends StatefulWidget {

  const RideBoardList({Key? key}) : super(key: key);

  @override
  _RideBoardListState createState() => _RideBoardListState();
}

class _RideBoardListState extends State<RideBoardList> {
  @override
  Widget build(BuildContext context) {
    // TODO: Make List<Ride>
    return const Text('Ride Board');
  }
}
