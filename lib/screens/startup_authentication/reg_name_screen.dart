import 'package:flutter/material.dart';
import 'package:tagalong/screens/startup_authentication/reg_gradyear_screen.dart';
import 'package:tagalong/util/form_sequence_utils.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

/// [RegNameScreen] is a Screen that contains a Form for receiving the first and last
/// name of a TagAlongUser.
class RegNameScreen extends StatefulWidget {
  const RegNameScreen({Key? key}) : super(key: key);

  @override
  State<RegNameScreen> createState() => _RegNameScreenState();
}

class _RegNameScreenState extends State<RegNameScreen> {
  // Form state
  final formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  RegExp exp = RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
        automaticallyImplyLeading: false,
        title: getProgressBarRow(filledIcons: 1, totalIcons: 3)
      ),
      body: Form(
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
                      "What is your first and last name?"
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        labelText: 'Name',
                        hintText: 'John Smith',
                        isDense: true
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a first and last name';
                        }
                        if (exp.hasMatch(value) == false) {
                          return 'Please enter a valid first and last name';
                        }
                        return null;
                      }
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
      )
    );
  }
}
