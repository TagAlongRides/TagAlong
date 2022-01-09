import 'package:flutter/material.dart';

class SchoolRegistrationForm extends StatefulWidget {
  const SchoolRegistrationForm({Key? key}) : super(key: key);

  @override
  _SchoolRegistrationFormState createState() => _SchoolRegistrationFormState();
}

class _SchoolRegistrationFormState extends State<SchoolRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.location_city_outlined),
              border: UnderlineInputBorder(),
              labelText: 'College/University',
            ),
            keyboardType: TextInputType.name,
          ),
          TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.school_outlined),
                border: const UnderlineInputBorder(),
                labelText: 'Graduating Year/Class',
              ),
              keyboardType: TextInputType.number
          ),
          TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.email_outlined),
                border: const UnderlineInputBorder(),
                labelText: 'University Email (.edu)',
              ),
              keyboardType: TextInputType.emailAddress
          ),
          TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.contact_phone_outlined),
                border: const UnderlineInputBorder(),
                labelText: 'Phone Number',
              ),
              keyboardType: TextInputType.phone
          )
        ]
      ),
    );
  }
}
