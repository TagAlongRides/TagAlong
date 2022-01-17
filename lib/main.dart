import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/landing_screen.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
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

class TagAlongApp extends StatefulWidget {
  const TagAlongApp({Key? key}) : super(key: key);

  @override
  State<TagAlongApp> createState() => _TagAlongAppState();
}

class _TagAlongAppState extends State<TagAlongApp> {

  @override
  Widget build(BuildContext context) {
    final theme = TagAlongTheme.light();
    // a single [AuthService] is now provided to all Widgets in the tree.
    return Provider(
      create: (BuildContext context) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        theme: theme,
        title: 'TagAlong App',
        home: AuthWrapper(),//LandingScreen(),
        routes: <String, WidgetBuilder> {
          '/register_user': (BuildContext context) => RegisterUserScreen(),
          '/ride_board': (BuildContext context) => RideBoardScreen(),
          '/login_screen': (BuildContext context) => LoginScreen(),
          '/registration_wrapper': (BuildContext context) => RegistrationWrapper()
        }
        ),
    );
  }

}

/// [AuthWrapper] will be a wrapper Widget which will utilize [AuthService] in
/// order to check whether the user is a Firebase user in the Auth. system or not.
/// Based on sign-in state, it will navigate to LoginScreen OR RegistrationWrapper.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();

    // Check if the user is signed-in or signed-out
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    _streamSubscription = authService.userStatus.listen((User? user){
      // 1. User is signed-in; Go to RegistrationWrapper
      if (user != null) {
        print('DEBUG: User is logged in in AuthWrapper.');
        Navigator.pushReplacementNamed(context, '/registration_wrapper');
      }
      // 2. User is signed-out; Go to LoginScreen
      else {
        print('DEBUG: User is logged out in AuthWrapper.');
        Navigator.pushReplacementNamed(context, '/login_screen');
      }
    });
  }

  @override
  void dispose() {
    // Once Widget is destroyed, unsubscribe from AuthService auth events.
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SafeArea(
        child: Center(
          child: CircularProgressIndicator()
        )
      )
    );
  }
}



