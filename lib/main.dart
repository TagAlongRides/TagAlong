import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const TagAlongApp());
}

class TagAlongApp extends StatelessWidget {
  const TagAlongApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TagAlong App',
      home: const Login()
      );
  }
}


