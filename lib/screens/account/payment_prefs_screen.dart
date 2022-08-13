import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  static const routeName = '/payment-methods';
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Payment Methods')),
      body: Center(child: Text('Manage Payment Methods')),
    );
  }
}
