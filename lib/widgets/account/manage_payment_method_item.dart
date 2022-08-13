import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:stripe_repo/stripe_repo.dart';

class ManagePaymentMethodItem extends StatelessWidget {
  final PaymentMethod paymentMethod;

  const ManagePaymentMethodItem(this.paymentMethod, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CardType cardType = CardType.otherBrand;
    String cardTypeName = 'Card';
    switch (paymentMethod.card.brand) {
      case 'visa':
        cardType = CardType.visa;
        cardTypeName = 'Visa';
        break;
      case 'americanExpress':
        cardType = CardType.americanExpress;
        cardTypeName = 'American Express';
        break;
      case 'mastercard':
        cardType = CardType.mastercard;
        cardTypeName = 'MasterCard';
        break;
      case 'discover':
        cardType = CardType.discover;
        cardTypeName = 'Discover';
        break;
      default:
        break;
    }

    return Dismissible(
      key: ValueKey(paymentMethod.id),
      background: Container(
        color: Colors.red,
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.all(20),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Remove payment method'),
                content: Text(
                    'Are you sure that you would like to remove $cardTypeName ending in ${paymentMethod.card.last4}?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO - Call Stripe to remove this payment method from account
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              );
            });
      },
      child: Column(
        children: [
          ListTile(
            tileColor: Colors.white,
            title: Text('$cardTypeName ending ${paymentMethod.card.last4}'),
            subtitle: Text('Exp ${paymentMethod.card.expMonth}/${paymentMethod.card.expYear}'),
            leading: Image.asset(
              CardTypeIconAsset[cardType].toString(),
              height: 24,
              package: 'flutter_credit_card',
            ),
            // trailing: Icon(),
          ),
          Divider(
            height: 0,
          ),
        ],
      ),
    );
  }
}
