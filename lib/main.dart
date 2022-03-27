import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/driver_registration_prompt_screen.dart';
import 'package:tagalong/screens/login_screen.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_campus.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_departure.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_dropoff.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_price_prefs.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_trip_details.dart';
import 'package:tagalong/screens/welcome_screen.dart';
import 'package:tagalong/viewmodels/filter_ride_view_model.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'screens/offer_ride/offer_ride_pickup.dart';
import 'themes/tagalong_theme.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

import 'viewmodels/offer_ride_view_model.dart';



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
    final theme = TagAlongTheme.light();
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (BuildContext context) => AuthService()),
        // TODO: May need `lazy: false`
        Provider<TagAlongUserViewModel>(create: (BuildContext context) => TagAlongUserViewModel()),
        ChangeNotifierProvider<RegisterDriverViewModel>(create: (BuildContext context) => RegisterDriverViewModel()),
        ChangeNotifierProvider<RideBoardViewModel>(create: (BuildContext context) => RideBoardViewModel()),
        ChangeNotifierProvider<OfferRideViewModel>(create: (BuildContext context) => OfferRideViewModel(tagAlongUserViewModel: Provider.of<TagAlongUserViewModel>(context, listen: false))),
        ChangeNotifierProvider<FilterRideViewModel>(create: (BuildContext context) => FilterRideViewModel())
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
          '/driver_registration_prompt': (BuildContext context) => const DriverRegistrationPromptScreen(),
          '/login_screen': (BuildContext context) => const LoginScreen(),
          '/welcome_screen': (BuildContext context) => const WelcomeScreen(),
          '/registration_wrapper': (BuildContext context) => const RegistrationWrapper(),
          '/offer_ride_campus': (BuildContext context) => const OfferRideCampus(),
          '/offer_ride_pickup': (BuildContext context) => const OfferRidePickup(),
          '/offer_ride_dropoff': (BuildContext context) => const OfferRideDropoff(),
          '/offer_ride_departure': (BuildContext context) => const OfferRideDeparture(),
          '/offer_ride_trip_details': (BuildContext context) => const OfferRideTripDetails(),
          '/offer_ride_price_prefs': (BuildContext context) => const OfferRidePricePrefs(),
        }
      ),
    );
  }
}

/// [AuthWrapper] will be a wrapper Widget which will utilize [AuthService] in
/// order to check whether the user is a Firebase user in the Auth system or not.
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
        logger.log.fine('User is logged-in in AuthWrapper. - Go to /registration_wrapper');
        Navigator.pushReplacementNamed(context, '/registration_wrapper');
      }
      // 2. User is signed-out; Go to LoginScreen
      else {
        logger.log.fine('User is logged-out in AuthWrapper. - Go to /login_screen');
        Navigator.pushReplacementNamed(context, '/login_screen');
      }
    });
  }

  @override
  void dispose() {
    // Once push() occurs, this widget will be destroyed, therefore need to
    // unsubscribe from AuthService auth events.
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

