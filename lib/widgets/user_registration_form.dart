import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

class UserRegistrationForm extends StatefulWidget {
  const UserRegistrationForm({Key? key}) : super(key: key);

  @override
  _UserRegistrationFormState createState() => _UserRegistrationFormState();
}

class _UserRegistrationFormState extends State<UserRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'US');
  String? gradValue = 'N/A';
  String? universityValue = Institution.VIRGINIA_TECH;
  String? affiliationValue = Affiliation.UNGRADUATE_STUDENT;
  List<String> affiliations = Affiliation.values;
  List<String> institutions = Institution.values;
  List<String> gradYears = [
    'N/A',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028'
  ];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    firstName.dispose();
    lastName.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel =
        Provider.of<TagAlongUserViewModel>(context, listen: false);

    // Keep TextFormFields on top, DropdownMenus below
    List<Widget> childrenList = [
      // 1. First Name
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: firstName,
            decoration: const InputDecoration(
              icon: Icon(Icons.account_circle_outlined),
              border: UnderlineInputBorder(),
              labelText: 'First Name*',
              helperText: "* Required"
            ),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a first name';
              }
              return null;
            }),
      ),

      // 2. Last Name
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: lastName,
            decoration: const InputDecoration(
              icon: Icon(Icons.account_circle),
              border: UnderlineInputBorder(),
              labelText: 'Last Name*',
              helperText: "* Required"
            ),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a last name';
              }
              return null;
            }),
      ),

      // 3. School Email
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              icon: Icon(Icons.email_outlined),
              border: UnderlineInputBorder(),
              labelText: 'University Email (.edu)*',
              helperText: "* Required"
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? value) {
              // TODO: Update email domain validation to be dynamic with institution selection
              if (value == null || value.isEmpty) {
                return 'Please enter a valid .edu email';
              }
              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@(vt|gmu).edu")
                  .hasMatch(value)) {
                return 'Please enter a valid @vt.edu email address';
              }
              return null;
            }),
      ),

      // 4. Phone Number
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber inputNumber) {
            phoneNumber = inputNumber;
          },
          initialValue: phoneNumber,
          textFieldController: phoneController,
          keyboardType: TextInputType.phone,
          keyboardAction: TextInputAction.next,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          ignoreBlank: true,
          validator: (String? phoneNumber) {
            if (phoneNumber == null || phoneNumber.isEmpty) {
              return 'Please enter a phone number';
            }
            else if (phoneNumber.length != 12) {
              return 'Please enter a valid phone number';
            }
          },
          inputDecoration: const InputDecoration(
            icon: Icon(Icons.phone),
            border: UnderlineInputBorder(),
            labelText: 'Phone Number*',
            helperText: "* Required"
          ),
        ),
      ),

      // 5. College/University
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: universityValue,
            decoration: const InputDecoration(
              icon: Icon(Icons.school_outlined),
              labelText: "University*",
              helperText: '* Required'
            ),
            // icon: const Icon(Icons.school_outlined),
            items: institutions
                .map<DropdownMenuItem<String>>((String institution) {
              return DropdownMenuItem<String>(
                  value: institution, child: Text(institution));
            }).toList(),
            onChanged: (String? value) {
              // Call setState() to rebuild the widget with the current value
              setState(() {
                universityValue = value!;
              });
            },
          )),

      // Graduation Year (Optional)
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: gradValue,
            decoration: const InputDecoration(
              icon: Icon(Icons.school_rounded),
              labelText: "Graduation Year (Optional)"),
            // icon: const Icon(Icons.school_outlined),
            items: gradYears.map<DropdownMenuItem<String>>((String grad) {
              return DropdownMenuItem<String>(value: grad, child: Text(grad));
            }).toList(),
            onChanged: (String? value) {
              // Call setState() to rebuild the widget with the current value
              setState(() {
                gradValue = value!;
              });
            },
          )),
    ];

    return Form(
      key: _formKey,
      child: Column(children: [
        // 1. Get a Scrollable View
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: childrenList,
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: Center(
            child: ElevatedButton(
              onPressed: () async {
                logger.log.fine('UserRegistrationForm - onPressed() Register Button');
                final form = _formKey.currentState;
                if (form != null) {
                  if (form.validate()) {
                    logger.log.fine('UserRegistrationForm - User registration was valid');
                    logger.log.fine('UserRegistrationForm -Attempting to write the following user data');
                    // TODO: Need better way of doing this + _updatedAt
                    Map<String, dynamic> registrationData = {
                      'first_name': firstName.text,
                      'last_name': lastName.text,
                      'email_address': emailController.text,
                      'phone_number': phoneController.text,
                      'institution': universityValue,
                      'grad_year': gradValue,
                      'is_registered': true
                    };

                    // Update the Unregistered TagAlongUser in database
                    await tagAlongUserViewModel.updateTagAlongUser(registrationData);
                    logger.log.fine('UserRegistrationForm - Updated user with registration information!');

                    // Send an email verification to `email_address`.
                    await tagAlongUserViewModel.sendEmailVerificationToUser();

                    // TODO: Move to "RegistrationComplete" Screen?
                    Navigator.pushReplacementNamed(context, '/welcome_screen');

                  }
                  else {
                    logger.log.fine('User registration was NOT valid.');
                  }
                }
              },
              child: const Text("Register"),
            ),
          ),
        )
      ]),
    );
  }
}
