import 'package:flutter/material.dart';
import 'tagalong_theme.dart';
import 'login.dart';

void main() {
  runApp(const TagAlongApp());
}

class TagAlongApp extends StatelessWidget {
  const TagAlongApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // TODO: Need to update theme..
    final theme = TagAlongTheme.light();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      title: 'TagAlong App',
      home: const Login()
      );
  }
}


