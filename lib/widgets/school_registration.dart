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
  bool _addGradYear = true;

  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'US');
  String? gradValue = '2022';
  String? universityValue = Institution.VIRGINIA_TECH;
  String? affiliationValue = Affiliation.UNGRADUATE_STUDENT;
  List<String> affiliations = Affiliation.values;
  List<String> institutions = Institution.values;
  List<String> gradYears = [
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
      // First Name
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: firstName,
            decoration: const InputDecoration(
              icon: Icon(Icons.account_circle_outlined),
              border: UnderlineInputBorder(),
              labelText: 'First Name',
            ),
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a first name';
              }
              return null;
            }),
      ),

      // Last Name
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: lastName,
            decoration: const InputDecoration(
              icon: Icon(Icons.account_circle),
              border: UnderlineInputBorder(),
              labelText: 'Last Name',
            ),
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a last name';
              }
              return null;
            }),
      ),

      // School Email
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              icon: Icon(Icons.email_outlined),
              border: UnderlineInputBorder(),
              labelText: 'University Email (.edu)',
            ),
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? value) {
              // TODO: Update email domain validation to be dynamic with institution selection
              if (value == null || value.isEmpty) {
                return 'Please enter a valid .edu email';
              }
              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@vt.edu")
                  .hasMatch(value)) {
                return 'Please enter a valid @vt.edu email address';
              }
              return null;
            }),
      ),

      // Phone Number
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber inputNumber) {
            phoneNumber = inputNumber;
          },
          initialValue: phoneNumber,
          textFieldController: phoneController,
          keyboardType: TextInputType.phone,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          ignoreBlank: true,
        ),
      ),

      // College/University
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: universityValue,
            decoration: const InputDecoration(
                icon: Icon(Icons.school_outlined), labelText: "University"),
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

      // Affiliation
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: affiliationValue,
            decoration: const InputDecoration(
                icon: Icon(Icons.school_rounded), labelText: "Affiliation"),
            // icon: const Icon(Icons.school_outlined),
            items: affiliations
                .map<DropdownMenuItem<String>>((String affiliation) {
              return DropdownMenuItem<String>(
                  value: affiliation, child: Text(affiliation));
            }).toList(),
            onChanged: (String? value) {
              // Call setState() to rebuild the widget with the current value.
              // Will check if `{Undergraduate, Graduate}` is chosen, if NOT,
              // remove the Graduation date from the list
              setState(() {
                affiliationValue = value!;
                if (['Undergraduate Student', 'Graduate Student']
                    .contains(value)) {
                  _addGradYear = true;
                } else {
                  _addGradYear = false;
                }
              });
            },
          )),

      if (_addGradYear)
        // Graduation Year - Dependant on `Affiliation`
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: DropdownButtonFormField<String>(
              value: gradValue,
              decoration: const InputDecoration(
                  icon: Icon(Icons.school_rounded),
                  labelText: "Graduation Year"),
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
                logger.log.fine('onPressed on Register Button');
                final form = _formKey.currentState;
                if (form != null) {
                  if (form.validate()) {
                    logger.log.fine('User registration was valid');
                    logger.log
                        .fine('Attempting to write the following user data');
                    // TODO: Need better way of doing this + _updatedAt
                    Map<String, dynamic> registrationData = {
                      'first_name': firstName.text,
                      'last_name': lastName.text,
                      'institution': universityValue,
                      'affiliation': affiliationValue,
                      'grad_year': gradValue,
                      'email_address': emailController.text,
                      'phone_number': phoneController.text,
                      'is_registered': true
                    };
                    logger.log.fine(registrationData.toString());

                    // Update the Unregistered TagAlongUser in database
                    await tagAlongUserViewModel
                        .updateTagAlongUser(registrationData);
                    logger.log
                        .fine('Updated user with registration information!');

                    // Send an email verification to `email_address`.
                    await tagAlongUserViewModel.sendEmailVerificationToUser();

                    // TODO: Move to "RegistrationComplete" Screen?
                    await Navigator.pushReplacementNamed(
                        context, '/ride_board');
                  } else {
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
