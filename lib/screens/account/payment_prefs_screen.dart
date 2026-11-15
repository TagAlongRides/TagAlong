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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: const EdgeInsets.all(12),
              child: const CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!.data.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PaymentPrefHeader('Saved Payment Methods'),
                Flexible(
                  fit: FlexFit.loose,
                  child: data.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'You haven' 't saved any payment methods yet. Try adding one!',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ManagePaymentMethodItem(data[index]);
                          },
                        ),
                ),
                const SizedBox(height: 12),
                const PaymentPrefHeader('Add a Payment Method'),
                const NewPaymentMethod(),
              ],
            );
          } else {
            print(snapshot.error);
            throw snapshot.error!;
          }
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
        style: TagAlongTheme.lightTextTheme.titleLarge,
      ),
    );
  }
}
