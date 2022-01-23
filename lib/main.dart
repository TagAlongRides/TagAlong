import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
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
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (BuildContext context) => AuthService()),
        Provider<TagAlongUserViewModel>(create: (BuildContext context) => TagAlongUserViewModel())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        theme: theme,
        title: 'TagAlong App',
        home: const AuthWrapper(),
        routes: <String, WidgetBuilder> {
          '/register_user': (BuildContext context) => const RegisterUserScreen(),
          '/register_driver': (BuildContext context) => const RegisterDriverScreen(),
          '/ride_board': (BuildContext context) => const RideBoardScreen(),
          '/login_screen': (BuildContext context) => const LoginScreen(),
          '/registration_wrapper': (BuildContext context) => const RegistrationWrapper(),
          // '/register_driver': (BuildContext context) => const RegisterDri
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
        print('DEBUG: User is logged-in in AuthWrapper. - Go to /registration_wrapper');
        Navigator.pushReplacementNamed(context, '/registration_wrapper');
      }
      // 2. User is signed-out; Go to LoginScreen
      else {
        print('DEBUG: User is logged-out in AuthWrapper. - Go to /login_screen');
        Navigator.pushReplacementNamed(context, '/login_screen');
      }
    });
  }

  @override
  void dispose() {
    // Once push() occurs, this widget will be destroyed, therefore need to
    // unsubscribe from AuthService auth events.
    // TODO: Perhaps keep open and have it automatically take us back here?
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (BuildContext context) => TagAlongUserViewModel(),
      child: Scaffold(
        appBar: AppBar(),
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator()
          )
        )
      ),
    );
  }
}



