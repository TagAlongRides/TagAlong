import 'package:flutter/material.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/widgets/user_registration_form.dart';

class UpdateUserForm extends StatefulWidget {
  final TagAlongUser _user;
  const UpdateUserForm(this._user, {Key? key}) : super(key: key);

  @override
  State<UpdateUserForm> createState() => _UpdateUserFormState();
}

class _UpdateUserFormState extends State<UpdateUserForm> {
  @override
  Widget build(BuildContext context) {
    return UserRegistrationForm(widget._user);
    // return Form(child: null);
  }
}
