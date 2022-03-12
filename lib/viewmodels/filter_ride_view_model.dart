import 'package:flutter/material.dart';


/// A ViewModel that maintains the state and functionality
/// of the "Filter Ride" flow (ModalBottomSheet)
class FilterRideViewModel with ChangeNotifier {
  bool toCampus = true;     // Defaults to true on Modal sheet
  DateTime? departureDate;


  /// Return a formatted string date to allow the user to know
  /// when they want to depart.
  String getFormattedDepartureDate() {
    String formattedDate = departureDate != null
        ? departureDate!.toIso8601String().split('T').first
        : 'Departure Date';
    return formattedDate;
  }

  /// Update the `toCampus` choice to true and notify listeners.
  void toCampusChoice() {
    toCampus = true;
    notifyListeners();
  }

  /// Update the `toCampus` choice to false and notify listeners.
  void fromCampusChoice() {
    toCampus = false;
    notifyListeners();
  }

  /// Update the `departureTime` to input and notify listeners.
  void updateDepartureDate(DateTime? departureDate) {
    this.departureDate = departureDate;
    notifyListeners();
  }

  /// Reset all attributes of the FilterRideViewModel
  void resetAll() {
    toCampus = true;
    departureDate = null;
    notifyListeners();
  }

}