import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/services/user_service.dart';
import 'package:tagalong/util/form_sequence_utils.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:tagalong/viewmodels/register_user_view_model.dart';

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
  final fullNameController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RegisterUserViewModel vm = Provider.of<RegisterUserViewModel>(context, listen: false);
    UserService us = serviceLocator.get<UserService>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
        automaticallyImplyLeading: false,
        title: getProgressBarRow(filledIcons: 1, totalIcons: 4)
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
                      controller: fullNameController,
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
                      validator: vm.validateAndUpdateName
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
                      us.signOut();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 24.0,
                      semanticLabel: "Move to next registration form",
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(context).pushNamed('reg/reg_gradyear');
                      }
                    },
                  )
                ]
              )
            )
          ]
        ),
      )
    );
  }
}