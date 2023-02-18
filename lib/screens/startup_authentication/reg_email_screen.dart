import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/main.dart';
import 'package:tagalong/services/user_service.dart';
import 'package:tagalong/util/constants.dart';
import 'package:tagalong/util/form_sequence_utils.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:tagalong/viewmodels/register_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

/// [RegEmailScreen] is a Screen that contains a Form for receiving the email and potential password
/// given the sign up provider
class RegEmailScreen extends StatefulWidget {
  const RegEmailScreen({Key? key}) : super(key: key);

  @override
  State<RegEmailScreen> createState() => _RegEmailScreenState();
}

class _RegEmailScreenState extends State<RegEmailScreen> {

  // Form state
  final formKey = GlobalKey<FormState>();
  final emailAddress = TextEditingController();

  @override
  void dispose() {
    emailAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RegisterUserViewModel vm = Provider.of<RegisterUserViewModel>(context, listen: false);
    UserService us = serviceLocator.get<UserService>();

    // Assign initial value of [emailAddress] controller to email if possible
    emailAddress.text = vm.getSchoolEmailFromFirebaseUser() ?? '';

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
            automaticallyImplyLeading: false,
            title: getProgressBarRow(filledIcons: 3, totalIcons: 4)
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                      "What is your university student email (.edu)?"
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                child: TextFormField(
                                    controller: emailAddress,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        labelText: 'Email',
                                        hintText: 'jsmith@vt.edu',
                                        helperText: "Please enter a valid Virginia Tech email",
                                        isDense: true
                                    ),
                                    validator: vm.validateAndUpdateEmail
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      size: 24.0,
                                      semanticLabel: "Go Back",
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 24.0,
                                      semanticLabel: "Move to next registration form",
                                    ),
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {

                                        // User has fully registered all their user information,
                                        // with the data being stored in the RegisterUserViewModel.
                                        // Register the TagAlongUserNew in firestore, creating a
                                        // Registered, but not verified TagAlongUser
                                        await us.registerTagAlongUser(
                                          name: vm.name!,
                                          emailAddress: vm.emailAddress!,
                                          gradYear: vm.graduationYear
                                        );

                                        // Pop all the routes and rebuild [RegistrationGate]
                                        await Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            'reg/reg_gate',
                                            (Route<dynamic> route) => false
                                        );
                                      }
                                    },
                                  )
                                ]
                            )
                        )
                      ]
                  ),
                ),
              ),
            ]
          ),
        )
    );
  }
}