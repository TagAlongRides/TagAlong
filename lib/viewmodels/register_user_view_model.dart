import 'package:flutter/material.dart';
import 'package:tagalong/util/log.dart' as logger;

class RegisterUserViewModel extends ChangeNotifier {

  // Basic user-inputted state for registering a user
  String? name;
  String? emailAddress;
  String? password;
  String? graduationYear;

  // Valid RegEx for full name validation
  final RegExp exp = RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");

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
    if (exp.hasMatch(name) == false) {
      return 'Please enter a valid first and last name';
    }
    // 2. Update name
    this.name = name;
    notifyListeners();
    return null;
  }

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
}