import 'package:flutter/material.dart';

class NotificationPrefsScreen extends StatelessWidget {
  static const routeName = '/notification-prefs';
  const NotificationPrefsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Preferences')),
      body: Center(child: Text('Notification Preferences')),
    );
  }
}
