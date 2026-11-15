import 'package:bulleted_list/bulleted_list.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/screens/stripe_connect_registration/driver_stripe_connect_registration_screen.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

class StripeInfoScreen extends StatelessWidget {
  const StripeInfoScreen({Key? key}) : super(key: key);
  static const routeName = '/stripe-info-screen';

  @override
  Widget build(BuildContext context) {
    final _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: true);
    final _tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    Future<void> _handlePress() async {
      Driver? driver = _registerDriverViewModel.createDriver();

      // 3. Navigate to Rideboard
      Navigator.of(context).pushNamed(DriverStripeConnectRegistrationScreen.routeName).then((value) async {
        if (value != null) {
          var _connectResponse = value as StripeConnectResponse;
          driver?.stripeAccountId = _connectResponse.data.accountId;

          //0.1 - Check of Stripe Account dont have any required action
          final stripeAccount = await StripeAccountRepository.instance.getAccount(_connectResponse.data.accountId);
          driver?.isStripeActive = stripeAccount.data.canReceivePayouts;

          // 1. Update our [TagAlongUser] in-memory
          Map<String, dynamic> data = {'driver_data': driver};
          _tagAlongUserViewModel.updateTagAlongUserInternal(data);

          // 2. Update [TagAlongUser] in Firestore
          _tagAlongUserViewModel.updateTagAlongUserFirestore();

          // 3. Navigate to Rideboard
          Navigator.pushReplacementNamed(context, RideBoardScreen.routeName);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 200,
        title: Row(
          children: [
            const Icon(
              Icons.hexagon_rounded,
              color: Colors.black,
            ),
            const SizedBox(width: 20),
            const Icon(
              Icons.hexagon_rounded,
              color: Colors.black,
            ),
            const SizedBox(width: 20),
            Expanded(
              // width: 200,
              // alignment: Alignment.centerRight,
              child: Text(
                'Last step before you start offering rides!',
                textAlign: TextAlign.right,
                style: TagAlongTheme.lightTextTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                children: [
                  Text(
                    'Let' 's set up your payment info',
                    style: TagAlongTheme.lightTextTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'By setting up your payment information through Stripe:',
                    style: TagAlongTheme.lightTextTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  BulletedList(
                    style: TagAlongTheme.lightTextTheme.bodyMedium,
                    bullet: const Icon(Icons.check),
                    listItems: const [
                      'You never need to ask your passengers when or how they are going to pay you',
                      'Payment information will be stored securely for future trips',
                      'You will automatically be paid out for rides you give within 2-3 business days',
                    ],
                    bulletColor: Colors.black,
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  LoadingButton(
                    onPressed: _handlePress,
                    text: 'Let\'s Go!',
                    // child: const Text(''),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(RideBoardScreen.routeName);
                    },
                    child: const Text(
                      'I\'ll finish later, take me to the Ride Board!',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    // child: const Text(''),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
