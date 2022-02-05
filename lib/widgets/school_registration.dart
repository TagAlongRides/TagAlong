import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;


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

  String? gradValue = '2022';
  String? universityValue = Institution.VIRGINIA_TECH;
  String? affiliationValue = Affiliation.UNGRADUATE_STUDENT;
  List<String> affiliations = Affiliation.values;
  List<String> institutions = Institution.values;
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid first name';
              }
              return null;
            }
        ),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid last name';
              }
              return null;
            }
        ),
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
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a valid .edu email';
              }
              return null;
            }
        ),
      ),

      // Phone Number
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

      // College/University
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: universityValue,
            decoration: const InputDecoration(
                icon: Icon(Icons.school_outlined),
                labelText: "University"
            ),
            // icon: const Icon(Icons.school_outlined),
            items: institutions
                .map<DropdownMenuItem<String>>((String institution) {
              return DropdownMenuItem<String>(
                  value: institution,
                  child: Text(institution)
              );
            }).toList(),
            onChanged: (String? value) {
              // Call setState() to rebuild the widget with the current value
              setState(() {
                universityValue = value!;
              });
            },

          )
      ),

      // Affiliation
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
                .map<DropdownMenuItem<String>>((String affiliation) {
              return DropdownMenuItem<String>(
                  value: affiliation,
                  child: Text(affiliation)
              );
            }).toList(),
            onChanged: (String? value) {
              // Call setState() to rebuild the widget with the current value.
              // Will check if `{Undergraduate, Graduate}` is chosen, if NOT,
              // remove the Graduation date from the list
              setState(() {
                affiliationValue = value!;
                if (['Undergraduate Student', 'Graduate Student'].contains(value)){
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
      // Graduation Year - Dependant on `Affiliation`
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
    ];

    return Form(
      key: _formKey,
      child: Column(
        children: [
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
                onPressed: (){
                  logger.log.fine('onPressed on Register Button');
                  final form = _formKey.currentState;
                  if (form != null) {
                    if (form.validate()) {
                      logger.log.fine('User registration was valid');
                      logger.log.fine('Attempting to write the following user data');
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
                      tagAlongUserViewModel.updateTagAlongUser(registrationData).then((_) {
                        logger.log.fine('Updated user with registration information!');
                        tagAlongUserViewModel.sendEmailVerificationToUser().then((_) {
                          Navigator.pushReplacementNamed(context, '/ride_board');
                        });
                      });
                      // tagAlongUserViewModel.sendEmailVerificationToUser();
                      // Navigator.pushReplacementNamed(context, '/ride_board');
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
        ]
      ),
    );
  }
}


