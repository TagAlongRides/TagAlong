import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/account/update_user_form.dart';
import 'package:tagalong/widgets/user_registration_form.dart';

class UpdatePersonalInfoScreen extends StatelessWidget {
  static const routeName = '/update-personal-info';
  UpdatePersonalInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user =
        Provider.of<TagAlongUserViewModel>(context, listen: false).tagAlongUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Personal Information'),
      ),
      body: UserRegistrationForm(user!),
    );
  }
}
