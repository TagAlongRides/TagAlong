import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/account/account_settings_screen.dart';
import 'package:tagalong/screens/account/add_payment_method_screen.dart';
import 'package:tagalong/screens/account/support_screen.dart';
import 'package:tagalong/screens/account/notification_prefs_screen.dart';
import 'package:tagalong/screens/account/payment_prefs_screen.dart';
import 'package:tagalong/screens/account/privacy_policy_screen.dart';
import 'package:tagalong/screens/account/update_personal_info_screen.dart';
import 'package:tagalong/screens/driver_registration_prompt_screen.dart';
import 'package:tagalong/screens/login_screen.dart';
import 'package:tagalong/screens/my_ride/my_ride_detail_screen.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_campus.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_departure.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_dropoff.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_price_prefs.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_trip_details.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/screens/ride_details.dart';
import 'package:tagalong/screens/startup_authentication/auth_home_screen.dart';
import 'package:tagalong/screens/stripe_connect_registration/driver_stripe_connect_registration_screen.dart';
import 'package:tagalong/screens/stripe_connect_registration/stripe_info_screen.dart';
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
  runApp(ChangeNotifierProvider(
    create: (context) => TagAlongUserViewModel(),
    child: const TagAlongAppNew()
  ));
}


class TagAlongAppNew extends StatelessWidget {
  const TagAlongAppNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
      home: const AuthGate(),
    );
  }
}


/// A Widget that will act as the medium for checking whether a [TagAlongUser] is registered or not.
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    // Check if the user is authenticated via Firebase and branch off of that
    return StreamBuilder<User?>(
        stream: tagAlongUserViewModel.authStateChanges(),
        builder: (context, snapshot) {

          // 1. WAITING - async op has begun
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                appBar: AppBar(
                    title: const Text("Setting user up...")
                ),
                body: const Center(
                    child: CircularProgressIndicator()
                )
            );
          }

          // 2. DONE - Stream has returned a DONE event - should never happen with "authStateChanges"
          else if (snapshot.connectionState == ConnectionState.done) {
            logger.log.fine('authStateChanges Stream emitted DONE event!');
            return const Text('Error');
          }

          // 3. ACTIVE - main branch; will continuously listen for auth state changes by the
          // user, including when they sign-out, hence no logic needs to be written for
          // navigating to a new screen after that, this will automatically handle it.
          else if (snapshot.connectionState == ConnectionState.active) {
            logger.log.fine('authStateChanges emitted active event');

            // 3a. User is signed-in as a Firebase Auth User - initialize [TagAlongUser] in vm.
            if (snapshot.hasData) {
              // TODO - query Firestore for our TagAlongUser and initialize
              return const RideBoardScreen();
            }

            // 3b. User is NOT signed in - prompt login
            else {
              logger.log.fine('AuthGate - user NOT logged in, going to AuthHomeScreen');
              return const AuthHomeScreen();
            }
          }
          else {
            return Text("Error");
          }
        }

    );
  }
}


class TagAlongApp extends StatelessWidget {
  const TagAlongApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = TagAlongTheme.light();
    // Note: By default, Providers are created "lazily", therefore only when
    // they are needed. We depend on [TagAlongUserViewModel] to be created
    // first, therefore when other Providers need it, it'll be ready.
    return ChangeNotifierProvider<AuthService>(
      create: (BuildContext context) => AuthService(),
      child: Consumer<AuthService>(builder: (context, auth, child) {
        auth.getUser()?.reload();
        logger.log.fine('Current auth user: ${auth.getUser().toString()}');
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<TagAlongUserViewModel>(create: (BuildContext context) => TagAlongUserViewModel()),
            ChangeNotifierProvider<RegisterDriverViewModel>(
                create: (BuildContext context) => RegisterDriverViewModel()),
            ChangeNotifierProvider<RideBoardViewModel>(create: (BuildContext context) => RideBoardViewModel()),
            ChangeNotifierProvider<OfferRideViewModel>(
                create: (BuildContext context) => OfferRideViewModel(
                    tagAlongUserViewModel: Provider.of<TagAlongUserViewModel>(context, listen: false))),
            ChangeNotifierProvider<FilterRideViewModel>(create: (BuildContext context) => FilterRideViewModel()),
            ChangeNotifierProvider<RideDetailsViewModel>(create: (BuildContext context) => RideDetailsViewModel()),
            ChangeNotifierProvider<UploadRideViewModel>(create: (BuildContext context) => UploadRideViewModel())
          ],
          child: MaterialApp(
            theme: theme,
            title: 'TagAlong App',
            home: auth.getUser()?.refreshToken == null || auth.getUser()?.refreshToken == ''
                ? LoginScreen()
                : const RegistrationWrapper(),
            routes: <String, WidgetBuilder>{
              RegisterUserScreen.routeName: (BuildContext context) => const RegisterUserScreen(),
              RegisterDriverScreen.routeName: (BuildContext context) => const RegisterDriverScreen(),
              RideBoardScreen.routeName: (BuildContext context) => const RideBoardScreen(),
              DriverRegistrationPromptScreen.routeName: (BuildContext context) =>
                  const DriverRegistrationPromptScreen(),
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
              SupportScreen.routeName: (context) => const SupportScreen(),
              NotificationPrefsScreen.routeName: (context) => const NotificationPrefsScreen(),
              PaymentMethodsScreen.routeName: (context) => const PaymentMethodsScreen(),
              PrivacyPolicyScreen.routeName: (context) => const PrivacyPolicyScreen(),
              AddPaymentMethodScreen.routeName: (context) => const AddPaymentMethodScreen(),
              StripeInfoScreen.routeName: (context) => const StripeInfoScreen(),
              MyRideDetailScreen.routeName: (context) => const MyRideDetailScreen(),
              // '/stripe-payment': (BuildContext context) =>
              //     const StripePaymentScreen(ride: ,),
            },
          ),
        );
      }),
    );
  }
}
