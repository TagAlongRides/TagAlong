import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/landing_screen.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/util/log.dart' as logger;

import 'themes/tagalong_theme.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up logging
  logger.setupLogger();

  // Run the TagAlong Application
  runApp(const TagAlongApp());
}

class TagAlongApp extends StatefulWidget {
  const TagAlongApp({Key? key}) : super(key: key);

  @override
  State<TagAlongApp> createState() => _TagAlongAppState();
}

class _TagAlongAppState extends State<TagAlongApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // TODO 12/29: Need to update theme..
    final theme = TagAlongTheme.light();
    // TODO: AuthService is available to everyone, may need to refactor in future
    return Provider(
      create: (BuildContext context) => AuthService(),
      child: MaterialApp(
          debugShowCheckedModeBanner: true,
          theme: theme,
          title: 'TagAlong App',
          // home: LoginScreen(),
          home: LandingScreen(),
          routes: <String, WidgetBuilder>{
            '/register_user': (BuildContext context) => RegisterUserScreen(),
            '/ride_board': (BuildContext context) => RideBoardScreen()
          }),
    );
  }
}
