import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/startup_authentication/reg_gradyear_screen.dart';
import 'package:tagalong/util/form_sequence_utils.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:tagalong/viewmodels/register_user_view_model.dart';

/// [RegEmailAndPassword] is a Screen that contains a Form for receiving the email and potential password
/// given the sign up provider
class RegEmailAndPassword extends StatefulWidget {
  const RegEmailAndPassword({Key? key}) : super(key: key);

  @override
  State<RegEmailAndPassword> createState() => _RegEmailAndPasswordState();
}

class _RegEmailAndPasswordState extends State<RegEmailAndPassword> {
  // Form state
  final formKey = GlobalKey<FormState>();
  final emailAddress = TextEditingController();
  // passwords shown ONLY if "SignUpMethod" is "Email"
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  // state for password obfuscation
  bool _obscured = true;

  @override
  void dispose() {
    emailAddress.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RegisterUserViewModel vm = Provider.of<RegisterUserViewModel>(context, listen: false);

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

                              // "Email" SignUpMethod Password Widgets
                              if (vm.signUpMethod == "Email")
                                const Padding(
                                    padding: EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
                                    child: Text(
                                        "Please create your account password"
                                    )
                                ),
                              if (vm.signUpMethod == "Email")
                              Padding(
                                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                child: TextFormField(
                                  controller: password,
                                  obscureText: _obscured,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    labelText: 'Password',
                                    isDense: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          _obscured
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscured = !_obscured;
                                        });
                                        print(_obscured);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              if (vm.signUpMethod == "Email")
                              Padding(
                                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                child: TextFormField(
                                  controller: confirmPassword,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      labelText: 'Confirm Password',
                                      isDense: true,
                                      helperText: "Enter a password at least 8 characters long"
                                  ),
                                  validator: (String? tmp) {
                                    return vm.validateAndUpdatePassword(password.text, confirmPassword.text);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 24.0,
                                    semanticLabel: "Move to next registration form",
                                  ),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const RegGradYearScreen())
                                      );
                                    }
                                  },
                                )
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
