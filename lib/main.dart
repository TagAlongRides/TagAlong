import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/account/account_settings_screen.dart';
import 'package:tagalong/screens/account/contact_us_screen.dart';
import 'package:tagalong/screens/account/notification_prefs_screen.dart';
import 'package:tagalong/screens/account/payment_prefs_screen.dart';
import 'package:tagalong/screens/account/privacy_policy_screen.dart';
import 'package:tagalong/screens/account/update_personal_info_screen.dart';
import 'package:tagalong/screens/driver_registration_prompt_screen.dart';
import 'package:tagalong/screens/login_screen.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_campus.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_departure.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_dropoff.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_price_prefs.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_trip_details.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/screens/ride_details.dart';
import 'package:tagalong/screens/stripe_connect_registration/driver_stripe_connect_registration_screen.dart';
import 'package:tagalong/screens/welcome_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/filter_ride_view_model.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

import 'screens/offer_ride/offer_ride_pickup.dart';
import 'themes/tagalong_theme.dart';
import 'viewmodels/offer_ride_view_model.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );
  await Firebase.initializeApp();

  // Set up logging
  logger.setupLogger();

  Stripe.publishableKey =
      'pk_test_51KrmEeHOJhcBOg6eRUYQ0r274bFJuDrXl87YoDf32FiU3KozWxYtUi5sgxBJfmw8ZvZQM9SjzWkgmYJMbnHTekEK00HyDQBaBU';
  await Stripe.instance.applySettings();

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
    // Note: By default, Providers are created "lazily", therefore only when
    // they are needed. We depend on [TagAlongUserViewModel] to be created
    // first, therefore when other Providers need it, it'll be ready.
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (BuildContext context) => AuthService()),
        // TODO: May need `lazy: false`
        Provider<TagAlongUserViewModel>(create: (BuildContext context) => TagAlongUserViewModel()),
        ChangeNotifierProvider<RegisterDriverViewModel>(create: (BuildContext context) => RegisterDriverViewModel()),
        ChangeNotifierProvider<RideBoardViewModel>(create: (BuildContext context) => RideBoardViewModel()),
        ChangeNotifierProvider<OfferRideViewModel>(
            create: (BuildContext context) =>
                OfferRideViewModel(tagAlongUserViewModel: Provider.of<TagAlongUserViewModel>(context, listen: false))),
        ChangeNotifierProvider<FilterRideViewModel>(create: (BuildContext context) => FilterRideViewModel()),
        ChangeNotifierProvider<RideDetailsViewModel>(create: (BuildContext context) => RideDetailsViewModel()),
        ChangeNotifierProvider<UploadRideViewModel>(create: (BuildContext context) => UploadRideViewModel())
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: true,
          theme: theme,
          title: 'TagAlong App',
          home: const AuthWrapper(),
          routes: <String, WidgetBuilder>{
            RegisterUserScreen.routeName: (BuildContext context) => const RegisterUserScreen(),
            RegisterDriverScreen.routeName: (BuildContext context) => const RegisterDriverScreen(),
            RideBoardScreen.routeName: (BuildContext context) => const RideBoardScreen(),
            DriverRegistrationPromptScreen.routeName: (BuildContext context) => const DriverRegistrationPromptScreen(),
            LoginScreen.routeName: (BuildContext context) => LoginScreen(),
            WelcomeScreen.routeName: (BuildContext context) => const WelcomeScreen(),
            RegistrationWrapper.routeName: (BuildContext context) => const RegistrationWrapper(),
            OfferRideCampus.routeName: (BuildContext context) => const OfferRideCampus(),
            OfferRidePickup.routeName: (BuildContext context) => const OfferRidePickup(),
            OfferRideDropoff.routeName: (BuildContext context) => const OfferRideDropoff(),
            OfferRideDeparture.routeName: (BuildContext context) => const OfferRideDeparture(),
            OfferRideTripDetails.routeName: (BuildContext context) => const OfferRideTripDetails(),
            OfferRidePricePrefs.routeName: (BuildContext context) => const OfferRidePricePrefs(),
            RideDetails.routeName: (BuildContext context) => const RideDetails(),
            DriverStripeConnectRegistrationScreen.routeName: (BuildContext context) =>
                const DriverStripeConnectRegistrationScreen(),
            AccountSettingsScreen.routeName: (context) => const AccountSettingsScreen(),
            UpdatePersonalInfoScreen.routeName: (context) => UpdatePersonalInfoScreen(),
            ContactUsScreen.routeName: (context) => const ContactUsScreen(),
            NotificationPrefsScreen.routeName: (context) => const NotificationPrefsScreen(),
            PaymentMethodsScreen.routeName: (context) => const PaymentMethodsScreen(),
            PrivacyPolicyScreen.routeName: (context) => const PrivacyPolicyScreen(),
            // '/stripe-payment': (BuildContext context) =>
            //     const StripePaymentScreen(ride: ,),
          }),
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

    checkAuthState();
  }

  void checkAuthState() async {
    // await FirebaseAuth.instance.signOut();
    // Check if the user is signed-in or signed-out
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    _streamSubscription = authService.userStatus.listen((User? user) {
      // 1. User is signed-in; Go to RegistrationWrapper
      if (user != null) {
        logger.log.fine('User is logged-in in AuthWrapper. - Go to /registration_wrapper');
        Navigator.pushReplacementNamed(context, RegistrationWrapper.routeName);
      }
      // 2. User is signed-out; Go to LoginScreen
      else {
        logger.log.fine('User is logged-out in AuthWrapper. - Go to /login_screen');
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
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
    return Scaffold(appBar: AppBar(), body: const SafeArea(child: Center(child: CircularProgressIndicator())));
  }
}
