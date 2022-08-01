import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/util/log.dart' as logger;

import '../../viewmodels/tagalong_user_view_model.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    var tagAlongUserViewModel =
        Provider.of<TagAlongUserViewModel>(context, listen: false);
    logger.log.fine('Account Build');
    // TODO: Solely for debugging the profile picture
    return Container(
      margin: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Column(
        children: [
          CircleAvatar(
            maxRadius: 100,
            backgroundImage: NetworkImage(
                tagAlongUserViewModel.tagAlongUser!.profilePictureUrl),
          ),
          if (tagAlongUserViewModel.tagAlongUser!.driverData != null)
            FutureBuilder<StripeAccountBalanceResponse>(
              future: StripeAccountRepository.instance.getAccountBalance(
                  tagAlongUserViewModel
                      .tagAlongUser!.driverData!.stripeAccountId!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Text(
                          'Available Account Balance : ${snapshot.data!.data.available.first.amount / 100} \$'),
                      LoadingButton(
                          onPressed: () async {
                            try {
                              final payout = await StripePayoutRepository
                                  .instance
                                  .payout(StripePayoutRequest(
                                      amount:
                                          '${snapshot.data!.data.available.first.amount}',
                                      accountId: tagAlongUserViewModel
                                          .tagAlongUser!
                                          .driverData!
                                          .stripeAccountId!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Success!: The Pauout was confirmed successfully!')));
                            } catch (error, stackTrace) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Payout Failed, Please try again later.')));
                            }
                          },
                          text: 'Payout')
                    ],
                  );
                }
                return Container();
              },
            ),
        ],
      ),
    );
  }
}
