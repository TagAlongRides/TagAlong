import 'package:flutter/material.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import '../../widgets/account/manage_payment_method_item.dart';
import '../../themes/tagalong_theme.dart';
import '../../widgets/account/new_payment_method.dart';

class PaymentMethodsScreen extends StatelessWidget {
  static const routeName = '/payment-methods';
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context);
    final _user = _tagAlongUserViewModel.tagAlongUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Payment Methods')),
      body: FutureBuilder<StripePaymentMethodResponse>(
        future: StripeCustomerRepository.instance.getPaymentMethod(_user!.stripeCustomerId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaymentPrefHeader('Saved Payment Methods'),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ManagePaymentMethodItem(data[index]);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                PaymentPrefHeader('Add a Payment Method'),
                NewPaymentMethod(),
              ],
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          return Container(
            padding: const EdgeInsets.all(12),
            child: const CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class PaymentPrefHeader extends StatelessWidget {
  final String text;
  const PaymentPrefHeader(
    this.text, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TagAlongTheme.lightTextTheme.headline6,
      ),
    );
  }
}
