import 'package:flutter/material.dart';
import 'package:tagalong/util/form_sequence_utils.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

/// [RegName] is a Screen that contains a Form for receiving the first and last
/// name of a TagAlongUser.
class RegName extends StatefulWidget {
  const RegName({Key? key}) : super(key: key);

  @override
  State<RegName> createState() => _RegNameState();
}

class _RegNameState extends State<RegName> {
  // Form state
  final formKey = GlobalKey<FormState>();
  final fullName = TextEditingController();
  RegExp exp = RegExp(r"/^[a-z ,.'-]+$/i");

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
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16),
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 24.0,
                  semanticLabel: "Move to next registration form",
                )
              )
            )
          ]
        ),
      )
    );
  }
}
