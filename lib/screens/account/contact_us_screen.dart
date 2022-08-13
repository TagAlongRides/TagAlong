import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  static const routeName = '/contact-us';
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us')),
      body: Center(child: Text('Contact Us')),
    );
  }
}
