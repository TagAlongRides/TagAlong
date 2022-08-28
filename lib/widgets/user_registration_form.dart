import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/screens/welcome_screen.dart';
import 'package:tagalong/services/auth_service.dart' as auth;
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

class UserRegistrationForm extends StatefulWidget {
  final TagAlongUser? _user;
  const UserRegistrationForm(this._user, {Key? key}) : super(key: key);

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
  String? gradValue;
  final defaultInstitution = Institution.VIRGINIA_TECH;
  // String? affiliationValue = Affiliation.UNGRADUATE_STUDENT;
  // List<String> affiliations = Affiliation.values;
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
    final _isNewUser = widget._user!.firstName == null || widget._user!.firstName.isEmpty;

    var _updatedUser = TagAlongUser(
      id: widget._user!.id,
      profilePictureUrl: widget._user!.profilePictureUrl,
      createdAt: widget._user!.createdAt,
      updatedAt: widget._user!.updatedAt,
      firstName: widget._user!.firstName,
      lastName: widget._user!.lastName,
      phoneNumber: widget._user!.phoneNumber,
      emailAddress: widget._user!.emailAddress,
      institution: widget._user!.institution,
      graduationYear: widget._user!.graduationYear,
    );
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    // Keep TextFormFields on top, DropdownMenus below
    List<Widget> childrenList = [
      // 1. First Name
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
          controller: _isNewUser ? firstName : null,
          initialValue: _isNewUser ? null : widget._user!.firstName,
          decoration: const InputDecoration(
              icon: Icon(Icons.account_circle_outlined),
              border: UnderlineInputBorder(),
              labelText: 'First Name*',
              helperText: "* Required"),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a first name';
            }
            return null;
          },
          onSaved: (value) {
            _updatedUser = TagAlongUser(
              id: _updatedUser.id,
              profilePictureUrl: _updatedUser.profilePictureUrl,
              createdAt: _updatedUser.createdAt,
              updatedAt: _updatedUser.updatedAt,
              firstName: value!,
              lastName: _updatedUser.lastName,
              phoneNumber: _updatedUser.phoneNumber,
              emailAddress: _updatedUser.emailAddress,
              institution: _updatedUser.institution,
              graduationYear: _updatedUser.graduationYear,
            );
          },
        ),
      ),

      // 2. Last Name
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
          controller: _isNewUser ? lastName : null,
          initialValue: _isNewUser ? null : widget._user!.lastName,
          decoration: const InputDecoration(
              icon: Icon(Icons.account_circle),
              border: UnderlineInputBorder(),
              labelText: 'Last Name*',
              helperText: "* Required"),
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a last name';
            }
            return null;
          },
          onSaved: (value) {
            _updatedUser = TagAlongUser(
              id: _updatedUser.id,
              profilePictureUrl: _updatedUser.profilePictureUrl,
              createdAt: _updatedUser.createdAt,
              updatedAt: _updatedUser.updatedAt,
              firstName: _updatedUser.firstName,
              lastName: value!,
              phoneNumber: _updatedUser.phoneNumber,
              emailAddress: _updatedUser.emailAddress,
              institution: _updatedUser.institution,
              graduationYear: _updatedUser.graduationYear,
            );
          },
        ),
      ),

      // 3. School Email
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: TextFormField(
          controller: _isNewUser ? emailController : null,
          initialValue: _isNewUser ? null : widget._user!.emailAddress,
          decoration: const InputDecoration(
              icon: Icon(Icons.email_outlined),
              border: UnderlineInputBorder(),
              labelText: 'University Email (.edu)*',
              helperText: "* Required"),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            // TODO: Update email domain validation to be dynamic with institution selection
            if (value == null || value.isEmpty) {
              return 'Please enter a valid .edu email';
            }
            // TODO: Uncomment after testing
            // if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@(vt|gmu|illinois).edu").hasMatch(value)) {
            //   return 'Please enter a valid @vt.edu email address';
            // }
            return null;
          },
          onSaved: (value) {
            _updatedUser = TagAlongUser(
              id: _updatedUser.id,
              profilePictureUrl: _updatedUser.profilePictureUrl,
              createdAt: _updatedUser.createdAt,
              updatedAt: _updatedUser.updatedAt,
              firstName: _updatedUser.firstName,
              lastName: _updatedUser.lastName,
              phoneNumber: _updatedUser.phoneNumber,
              emailAddress: value!,
              institution: _updatedUser.institution,
              graduationYear: _updatedUser.graduationYear,
            );
          },
        ),
      ),

      // 4. Phone Number
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: InternationalPhoneNumberInput(
          onInputChanged: (PhoneNumber inputNumber) {
            phoneNumber = inputNumber;
          },
          initialValue: _isNewUser
              ? phoneNumber
              : PhoneNumber(
                  phoneNumber: widget._user!.phoneNumber,
                  isoCode: 'US',
                ),
          textFieldController: phoneController,
          keyboardType: TextInputType.phone,
          keyboardAction: TextInputAction.next,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          ignoreBlank: true,
          validator: (String? phoneNumber) {
            if (phoneNumber == null || phoneNumber.isEmpty) {
              return 'Please enter a phone number';
            } else if (phoneNumber.length != 12) {
              return 'Please enter a valid phone number';
            }
          },
          onSaved: (value) {
            _updatedUser = TagAlongUser(
              id: _updatedUser.id,
              profilePictureUrl: _updatedUser.profilePictureUrl,
              createdAt: _updatedUser.createdAt,
              updatedAt: _updatedUser.updatedAt,
              firstName: _updatedUser.firstName,
              lastName: _updatedUser.lastName,
              phoneNumber: value.phoneNumber!,
              emailAddress: _updatedUser.emailAddress,
              institution: _updatedUser.institution,
              graduationYear: _updatedUser.graduationYear,
            );
          },
          inputDecoration: const InputDecoration(
              icon: Icon(Icons.phone),
              border: UnderlineInputBorder(),
              labelText: 'Phone Number*',
              helperText: "* Required"),
        ),
      ),

      // 5. College/University
      if (_isNewUser) // For now, do not allow users to change their college
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: DropdownButtonFormField<String>(
              value: _isNewUser ? defaultInstitution : widget._user!.institution,
              decoration: const InputDecoration(
                  icon: Icon(Icons.school_outlined), labelText: "University*", helperText: '* Required'),
              // icon: const Icon(Icons.school_outlined),
              items: institutions.map<DropdownMenuItem<String>>((String institution) {
                return DropdownMenuItem<String>(value: institution, child: Text(institution));
              }).toList(),
              onChanged: (String? value) {
                _updatedUser = TagAlongUser(
                  id: _updatedUser.id,
                  profilePictureUrl: _updatedUser.profilePictureUrl,
                  createdAt: _updatedUser.createdAt,
                  updatedAt: _updatedUser.updatedAt,
                  firstName: _updatedUser.firstName,
                  lastName: _updatedUser.lastName,
                  phoneNumber: _updatedUser.phoneNumber,
                  emailAddress: _updatedUser.emailAddress,
                  institution: value!,
                  graduationYear: _updatedUser.graduationYear,
                );
              },
              onSaved: (String? value) {
                _updatedUser = TagAlongUser(
                  id: _updatedUser.id,
                  profilePictureUrl: _updatedUser.profilePictureUrl,
                  createdAt: _updatedUser.createdAt,
                  updatedAt: _updatedUser.updatedAt,
                  firstName: _updatedUser.firstName,
                  lastName: _updatedUser.lastName,
                  phoneNumber: _updatedUser.phoneNumber,
                  emailAddress: _updatedUser.emailAddress,
                  institution: value!,
                  graduationYear: _updatedUser.graduationYear,
                );
              },
            )),

      // Graduation Year (Optional)
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: DropdownButtonFormField<String>(
            value: _isNewUser ? gradValue : widget._user!.graduationYear,

            decoration:
                const InputDecoration(icon: Icon(Icons.school_rounded), labelText: "Graduation Year (Optional)"),
            // icon: const Icon(Icons.school_outlined),
            items: gradYears.map<DropdownMenuItem<String>>((String grad) {
              return DropdownMenuItem<String>(value: grad, child: Text(grad));
            }).toList(),
            onChanged: (String? value) {
              _updatedUser = TagAlongUser(
                id: _updatedUser.id,
                profilePictureUrl: _updatedUser.profilePictureUrl,
                createdAt: _updatedUser.createdAt,
                updatedAt: _updatedUser.updatedAt,
                firstName: _updatedUser.firstName,
                lastName: _updatedUser.lastName,
                phoneNumber: _updatedUser.phoneNumber,
                institution: _updatedUser.institution,
                emailAddress: _updatedUser.emailAddress,
                graduationYear: value,
              );
              gradValue = value!;
            },
            onSaved: (value) {
              _updatedUser = TagAlongUser(
                id: _updatedUser.id,
                profilePictureUrl: _updatedUser.profilePictureUrl,
                createdAt: _updatedUser.createdAt,
                updatedAt: _updatedUser.updatedAt,
                firstName: _updatedUser.firstName,
                lastName: _updatedUser.lastName,
                phoneNumber: _updatedUser.phoneNumber,
                institution: _updatedUser.institution,
                emailAddress: _updatedUser.emailAddress,
                graduationYear: value,
              );
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
                logger.log.fine('Attempting to save ${_updatedUser.toString()}');
                final form = _formKey.currentState;
                logger.log.fine('form is null? ${form == null}');
                if (form != null) {
                  if (form.validate()) {
                    form.save();
                    logger.log.fine('UserRegistrationForm - User registration was valid');
                    logger.log.fine('UserRegistrationForm -Attempting to write the following user data');
                    Map<String, dynamic> registrationData = {
                      'first_name': _updatedUser.firstName,
                      'last_name': _updatedUser.lastName,
                      'email_address': _updatedUser.emailAddress,
                      'phone_number': _updatedUser.phoneNumber,
                      'institution': _updatedUser.institution,
                      'graduation_year': _updatedUser.graduationYear,
                      'is_registered': true
                    };
                    logger.log.fine('REG DATA: ${registrationData.toString()}');

                    if (_isNewUser) {
                      // 0. Create Stripe Account and add Account id in user doc
                      final response = await StripeCustomerRepository.instance.createCustomer(
                        StripeCustomerCreateRequest(
                          email: emailController.text,
                          name: firstName.text,
                        ),
                      );
                      registrationData['stripe_customer_id'] = response.data.id;
                    }

                    // Update our [TagAlongUser] in-memory
                    tagAlongUserViewModel.updateTagAlongUserInternal(registrationData);

                    // Update the Registered TagAlongUser in Firestore
                    await tagAlongUserViewModel.updateTagAlongUserFirestore();
                    logger.log.fine('UserRegistrationForm - Updated user with registration information!');

                    // Update the logged in user in Firebase Auth
                    await tagAlongUserViewModel.updateTagAlongUserAuth();

                    // Send an email verification to `email_address`.
                    if (_isNewUser || true) {
                      await tagAlongUserViewModel.sendEmailVerificationToUser();
                    }
                    // Navigate to Welcome screen if new user, or back to previous page if existing
                    if (_isNewUser) {
                      Navigator.pushReplacementNamed(context, WelcomeScreen.routeName);
                    } else {
                      // FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.of(context).pop();
                    }
                  } else {
                    logger.log.fine('User registration was NOT valid.');
                  }
                }
              },
              child: _isNewUser ? const Text("Register") : const Text("Apply Changes"),
            ),
          ),
        )
      ]),
    );
  }
}
