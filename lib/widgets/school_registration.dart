import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';

class SchoolRegistrationForm extends StatefulWidget {
  const SchoolRegistrationForm({Key? key}) : super(key: key);

  @override
  _SchoolRegistrationFormState createState() => _SchoolRegistrationFormState();
}

class _SchoolRegistrationFormState extends State<SchoolRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final uni_controller = TextEditingController();
  final year_controller = TextEditingController();
  final email_controller = TextEditingController();
  final phone_controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    uni_controller.dispose();
    year_controller.dispose();
    email_controller.dispose();
    phone_controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    AuthService _authService = Provider.of<AuthService>(context, listen: false);
    String? uid = _authService.getUid();
    // TODO: Will most likely need to make DatabaseService a Provider
    DatabaseService _databaseService = DatabaseService();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Which University
            TextFormField(
              controller: uni_controller,
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
                controller: year_controller,
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
                controller: email_controller,
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
                controller: phone_controller,
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
                          print('DEBUG: Attempt to write the user data...');
                          _databaseService.update_user_data(
                              uid,
                              uni_controller.text,
                              int.parse(year_controller.text),
                              email_controller.text,
                              phone_controller.text);
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
                            print('DEBUG: School registration was valid - Navigating to DriverRegistrationScreen');

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
