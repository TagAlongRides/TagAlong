import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  static const routeName = '/support-contact-us';
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FAQs & Support')),
      body: Center(child: Text('FAQs & Support')),
    );
  }
}
