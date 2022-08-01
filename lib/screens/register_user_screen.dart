import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/user_registration_form.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({Key? key}) : super(key: key);

  @override
  _RegisterUserScreenState createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  @override
  Widget build(BuildContext context) {
    var authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          toolbarHeight: 100,
          // actions: [
          //   // TODO: STRICTLY DEBUGGING - NEED TO TAKE OUT
          //   OutlinedButton(
          //       child: const Text('Sign Out'),
          //       onPressed: (() {
          //         authService.signOut();
          //       }))
          // ],
          title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 16),
                Text('School Information', style: TextStyle(fontSize: 24.0)),
                Text('Nice to meet you!',
                    style:
                        TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
              ])),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: UserRegistrationForm(),
          ),
        ),
      ),
    );
  }
}

/// [RegistrationWrapper] will be a wrapper Widget which will utilize [DataService]
/// in order to check whether the user is a "registered" user, therefore has an
/// account in the [users] collection within Cloud Firestore.
class RegistrationWrapper extends StatefulWidget {
  const RegistrationWrapper({Key? key}) : super(key: key);

  @override
  _RegistrationWrapperState createState() => _RegistrationWrapperState();
}

class _RegistrationWrapperState extends State<RegistrationWrapper> {
  Future<void> _setUpUser(TagAlongUserViewModel vm) async {
    await vm.setUpUser(vm.getUid() ?? '');
    bool? isRegistered = vm.isRegistered();

    if (isRegistered == true) {
      logger.log.fine(
          '_setUpUser() - User is registered in register_user_screen. To Rideboard');
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/ride_board');
      });
    }
    // 2. User is NOT registered
    else {
      logger.log.fine(
          '_setUpUser() - User is NOT registered in register_user_screen. To User Registration');
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/register_user');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    TagAlongUserViewModel tagAlongUserViewModel =
        Provider.of<TagAlongUserViewModel>(context, listen: false);
    _setUpUser(tagAlongUserViewModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body:
            const SafeArea(child: Center(child: CircularProgressIndicator())));
  }
}
