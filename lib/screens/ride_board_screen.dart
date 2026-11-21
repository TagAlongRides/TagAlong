import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/screens/account/account_settings_screen.dart';
import 'package:tagalong/screens/my_ride/my_ride_screen.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_campus.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';
import 'package:tagalong/widgets/rideboard/rideboard.dart';

/// The signed-in home: Ride Board, My Rides and Account tabs under a floating
/// pill nav, with the "Offer a ride" + in the middle.
class RideBoardScreen extends StatefulWidget {
  const RideBoardScreen({Key? key}) : super(key: key);
  static const routeName = '/ride_board';

  /// Index of the My Rides tab, for screens that want to land there.
  static const myRidesTab = 1;

  @override
  _RideBoardScreenState createState() => _RideBoardScreenState();
}

class _RideBoardScreenState extends State<RideBoardScreen> {
  static const _items = [
    TagAlongNavItem(label: 'Board', icon: Icons.home_outlined),
    TagAlongNavItem(label: 'My Rides', icon: Icons.directions_car_outlined),
    TagAlongNavItem(label: 'Account', icon: Icons.person_outline_rounded),
  ];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    logger.log.fine('RideboardScreen Build');

    // Only the visible tab is built, so My Rides re-reads its rides each time
    // it is opened (the old TabBarView behaved the same way).
    final Widget body = switch (_selected) {
      1 => MyRideScreen(onFindRide: () => setState(() => _selected = 0), onOfferRide: _onOfferRide),
      2 => const AccountSettingsScreen(),
      _ => const RideBoard(),
    };

    return Scaffold(
      extendBody: true,
      body: KeyedSubtree(key: ValueKey(_selected), child: body),
      bottomNavigationBar: TagAlongBottomNav(
        items: _items,
        selected: _selected,
        offerAfter: 0,
        onSelected: (i) => setState(() => _selected = i),
        onOffer: _onOfferRide,
      ),
    );
  }

  /// Checks the user can post a ride, explaining what is missing if not, and
  /// opens the Offer a Ride flow if they can.
  Future<void> _onOfferRide() async {
    final userViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    AuthService().reloadUser();
    final driverData = userViewModel.tagAlongUser?.driverData;

    if (!(driverData?.isStripeActive ?? false) && driverData?.stripeAccountId != null) {
      final stripeAccount = await StripeAccountRepository.instance.getAccount(driverData!.stripeAccountId!);
      driverData.isStripeActive = stripeAccount.data.canReceivePayouts;

      // 1. Update our [TagAlongUser] in-memory
      userViewModel.updateTagAlongUserInternal({'driver_data': driverData});

      // 2. Update [TagAlongUser] in Firestore
      await userViewModel.updateTagAlongUserFirestore();
    }
    if (!mounted) return;

    final hasDriverData = driverData != null;
    final isActiveDriver = userViewModel.isActiveDriver();
    final isStripeActive = userViewModel.isStripeActive();
    final isEmailVerified = userViewModel.isEmailVerified();
    logger.log.fine('RideBoardScreen - isActiveDriver: $isActiveDriver');

    if (!isEmailVerified) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verify email'),
            content: const Text(
                'To keep your travel safe, Tagalong requires every user to verify their email address before posting or booking a ride.'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    userViewModel.sendEmailVerificationToUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification email sent to ${userViewModel.tagAlongUser?.emailAddress}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Resend Verification')),
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
            ],
          );
        },
      );
    } else if (!hasDriverData) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Not a Driver'),
            content: const Text('You’re almost ready to post rides! Create your driver profile to get started.'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushNamed(RegisterDriverScreen.routeName);
                  },
                  child: const Text('Create profile')),
            ],
          );
        },
      );
    } else if (!isStripeActive) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('We couldn’t collect your payment details'),
            content:
                const Text('Oops! There was an issue with your Stripe registration, please try registering again.'),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pushNamed(RegisterDriverScreen.routeName);
                  },
                  child: const Text('Register')),
            ],
          );
        },
      );
    } else if (isActiveDriver) {
      logger.log.fine('RideBoardScreen - Going to OfferRideCampus');
      Navigator.pushNamed(context, OfferRideCampus.routeName);
    }
  }
}
