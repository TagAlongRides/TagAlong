import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/services/auth_service.dart';
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
    // TODO: AuthService is available to everyone, may need to refactor in future
    return Provider(
      create: (BuildContext context) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        theme: theme,
        title: 'TagAlong App',
        home: const LoginScreen(),
        routes: <String, WidgetBuilder> {
          '/register_user': (BuildContext context) => RegisterUserScreen()
        }
        ),
    );
  }
}


