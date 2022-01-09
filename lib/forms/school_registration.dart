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
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Which University
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.location_city_outlined),
                border: UnderlineInputBorder(),
                labelText: 'College/University',
              ),
              keyboardType: TextInputType.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid school';
                }
                return null;
              }
            ),

            // 2. Graduation Year
            TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.school_outlined),
                  border: const UnderlineInputBorder(),
                  labelText: 'Graduating Year/Class',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid graduating year';
                  }
                  return null;
                }
            ),

            // 3. School Email
            TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.email_outlined),
                  border: const UnderlineInputBorder(),
                  labelText: 'University Email (.edu)',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid .edu email';
                  }
                  return null;
                }
            ),

            // 4. Phone Number
            TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.contact_phone_outlined),
                  border: const UnderlineInputBorder(),
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                }
            ),
            SizedBox(height: 40),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      print('onPressed');
                      final form = _formKey.currentState;
                      print('form is null: $form');
                      if (form != null) {
                        if (form.validate()) {
                          print('DEBUG: School registration was valid - Navigating to RideBoardScreen');
                        }
                        else {
                          print('DEBUG: SCHOOL REGISTRATION NOT VALID');
                        }
                      }

                    },
                    child: Text("Skip Driver"),
                  ),
                  ElevatedButton(
                      onPressed: (){
                        final form = _formKey.currentState;
                        if (form != null) {
                          if (form.validate()) {
                            print(
                                'DEBUG: School registration was valid - Navigating to DriverRegistrationScreen');
                          }
                          else {
                            print('DEBUG: SCHOOL REGISTRATION NOT VALID');
                          }
                        }
                      },
                      child: Text("Create Driver")
                  )
                ]
            )
          ]
        ),
      ),
    );
  }
}
