import 'package:flutter/material.dart';
import 'package:tagalong/util/log.dart' as logger;

class RegisterUserViewModel extends ChangeNotifier {

  // Basic user-inputted state for registering a user
  String? name;
  String? emailAddress;
  String? password;
  String? graduationYear;

  /// Updates [name]
  ///
  /// This function will also notify all listeners to rebuild.
  void updateName({required String name}) {
    this.name = name;
    logger.log.fine('updateName($name) - notifying listeners');
    notifyListeners();
  }
}