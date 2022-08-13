import 'package:flutter/material.dart';
import 'package:tagalong/screens/account/add_payment_method_screen.dart';

class NewPaymentMethod extends StatelessWidget {
  const NewPaymentMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      title: Text('Credit/Debit Card'),
      leading: Icon(Icons.credit_card_outlined),
      trailing: Icon(Icons.chevron_right_outlined),
      onTap: () {
        Navigator.of(context).pushNamed(AddPaymentMethodScreen.routeName);
      },
    );
  }
}
