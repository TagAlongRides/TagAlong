import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';


class SchoolRegistrationForm extends StatefulWidget {
  const SchoolRegistrationForm({Key? key}) : super(key: key);

  @override
  _SchoolRegistrationFormState createState() => _SchoolRegistrationFormState();
}

class _SchoolRegistrationFormState extends State<SchoolRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool _addGradYear = true;
  // TODO: Enum changes
  String? gradValue = '2022';
  String? universityValue = 'Virginia Tech';
  String? affiliationValue = 'Undergraduate';
  List<String> affiliations = ['Undergraduate', 'Graduate', 'Post-doc', 'Faculty/Staff', 'Other'];
  List<String> gradYears = ['2022', '2023', '2024', '2025', '2026', '2027', '2028'];

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
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    List<Widget> childrenList = [
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid first name';
              }
              return null;
            }
        ),
      ),

      // 2. Last Name
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: lastName,
            decoration: const InputDecoration(
              icon: Icon(Icons.account_circle),
              border: UnderlineInputBorder(),
              labelText: 'Last Name',
            ),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid last name';
              }
              return null;
            }
        ),
      ),

      // 3. College/University
      Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: universityValue,
            decoration: const InputDecoration(
                icon: Icon(Icons.school_outlined),
                labelText: "University"
            ),
            // icon: const Icon(Icons.school_outlined),
            items: const [
              // TODO: Fix with Enums
              DropdownMenuItem<String>(
                  value: "Virginia Tech",
                  child: Text("Virginia Tech")
              ),

            ],
            onChanged: (String? value) {
              // Call setState() to rebuild the widget with the current value
              setState(() {
                universityValue = value!;
              });
            },

          )
      ),

      // 4. Affiliation?
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: affiliationValue,
            decoration: const InputDecoration(
                icon: Icon(Icons.school_rounded),
                labelText: "Affiliation"
            ),
            // icon: const Icon(Icons.school_outlined),
            items: affiliations
                .map<DropdownMenuItem<String>>((String affliation) {
              return DropdownMenuItem<String>(
                  value: affliation,
                  child: Text(affliation)
              );
            }).toList(),
            onChanged: (String? value) {
              // Call setState() to rebuild the widget with the current value.
              // Will check if `{Undergraduate, Graduate}` is chosen, if NOT,
              // remove the Graduation date from the list
              setState(() {
                affiliationValue = value!;
                if (['Undergraduate', 'Graduate'].contains(value)){
                  _addGradYear = true;
                }
                else {
                  _addGradYear = false;
                }
              });
            },
          )
      ),

      if (_addGradYear)
      // 5. Graduation Year - Dependant on `Affiliation`
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: DropdownButtonFormField<String>(
              value: gradValue,
              decoration: const InputDecoration(
                  icon: Icon(Icons.school_rounded),
                  labelText: "Graduation Year"
              ),
              // icon: const Icon(Icons.school_outlined),
              items: gradYears
                  .map<DropdownMenuItem<String>>((String grad) {
                return DropdownMenuItem<String>(
                    value: grad,
                    child: Text(grad)
                );
              }).toList(),
              onChanged: (String? value) {
                // Call setState() to rebuild the widget with the current value
                setState(() {
                  gradValue = value!;
                });
              },
            )
        ),

      // 6. School Email
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: emailController,
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
      ),

      // 7. Phone Number
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
            controller: phoneController,
            decoration: const InputDecoration(
              icon: Icon(Icons.contact_phone_outlined),
              border: UnderlineInputBorder(),
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
      ),

      SizedBox(height: 40),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: (){
                logger.log.fine('onPressed on Skip Driver');
                final form = _formKey.currentState;
                logger.log.fine('form is null: $form');
                if (form != null) {
                  if (form.validate()) {
                    logger.log.fine('DEBUG: School registration was valid - Navigating to RideBoardScreen');
                    logger.log.fine('DEBUG: Attempt to write the user data...');
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
                    tagAlongUserViewModel.updateTagAlongUser(registrationData);
                    Navigator.pushReplacementNamed(context, '/ride_board');
                  }
                  else {
                    logger.log.fine('DEBUG: SCHOOL REGISTRATION NOT VALID');
                  }
                }

              },
              child: const Text("Skip Driver"),
            ),
            ElevatedButton(
                onPressed: (){
                  logger.log.fine('onPressed on Create Driver');
                  final form = _formKey.currentState;
                  if (form != null) {
                    if (form.validate()) {

                      logger.log.fine('DEBUG: School registration was valid - Navigating to RideBoardScreen');
                      logger.log.fine('DEBUG: Attempt to write the user data...');
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
                      tagAlongUserViewModel.updateTagAlongUser(registrationData);
                      Navigator.pushReplacementNamed(context, '/register_driver');

                    }
                    else {
                      logger.log.fine('DEBUG: SCHOOL REGISTRATION NOT VALID');
                    }
                  }
                },
                child: const Text("Create Driver")
            )
          ]
      )
    ];

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: childrenList,
        ),
      ),
    );
  }


}

