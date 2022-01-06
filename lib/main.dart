import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'themes/tagalong_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Run the TagAlong Application
  runApp(const TagAlongApp());
}

class TagAlongApp extends StatelessWidget {
  const TagAlongApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // TODO 12/29: Need to update theme..
    final theme = TagAlongTheme.light();
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: theme,
      title: 'TagAlong App',
      home: const LoginScreen()
      );
  }
}


