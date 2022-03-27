import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import '../../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return const Text('Messages');
  }
}
