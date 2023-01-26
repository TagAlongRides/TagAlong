import 'package:flutter/material.dart';
import 'package:tagalong/util/log.dart' as logger;

class RegisterUserViewModel extends ChangeNotifier {

  // Basic user-inputted state for registering a user
  String? name;
  String? emailAddress;
  String? password;
  String? graduationYear;

  // Sign up provider string
  String? signUpMethod;

  // Valid RegEx for full name validation
  final RegExp nameExp = RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");

  // Valid RegEx for school email ending in ".edu"
  final RegExp emailExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.+-]+\.edu$");

  // Valid graduation years
  final List<String?> gradYears = ['2023', '2024', '2025', '2026', '2027', '2028', null];

  /// Validates and updates [name] and notifies listeners
  ///
  /// Returns error string on invalid input and null on correct.
  String? validateAndUpdateName(String? name) {
    // 1. Basic client-side validation
    if (name == null || name.isEmpty) {
      return 'Please enter a first and last name';
    }
    if (nameExp.hasMatch(name) == false) {
      return 'Please enter a valid first and last name';
    }
    // 2. Update name
    this.name = name;
    notifyListeners();
    return null;
  }

  /// Validates and updates [graduationYear] and notifies listeners
  ///
  /// Returns error string on invalid input and null on correct.
  String? validateAndUpdateYear(String? year) {
    // 1. client-side validation
    if (gradYears.contains(year) == false) {
      return "Please choose a valid year";
    }
    // 2. Update year
    graduationYear = year;
    notifyListeners();
    return null;
  }

  /// Validates and updates [password] and notifies listeners
  ///
  /// Returns error string on invalid input and null on correct.
  String? validateAndUpdatePassword(String password, String confirmPassword) {
    // 1. Client-side validation that passwords are same
    if (password != confirmPassword) {
      return "The two passwords are not equal";
    }
    else {
      if (confirmPassword.length < 8) {
        return "Password must be at least 8 characters long";
      }
    }
    // 2. update password
    this.password = password;
    notifyListeners();
    return null;
  }

  /// Validates and updates [emailAddress] and notifies listeners
  ///
  /// Returns error string on invalid input and null on correct.
  String? validateAndUpdateEmail(String? emailAddress) {
    // 1. client-side validation 
    if (emailAddress == null) {
      return "Please enter a school email";
    }
    if (emailExp.hasMatch(emailAddress) == false) {
      return "Please enter a valid school email";
    }
    // TODO: Currently allowing all .edu emails for testing
    // else {
    //   if (emailAddress.contains("@vt.edu") == false) {
    //     return "Please enter a valid Virginia Tech email";
    //   }
    // }
    // 2. update
    this.emailAddress = emailAddress;
    notifyListeners();
    return null;
  }
  
}