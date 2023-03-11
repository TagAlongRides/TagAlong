import 'package:flutter/material.dart';

/// A ViewModel that maintains the state and functionality
/// of the "Filter Ride" flow (ModalBottomSheet).
/// Note: the actual filters Map exists in RideBoardViewModel
class FilterRideViewModel with ChangeNotifier {
  bool toCampus = false; // Defaults to true on Modal sheet
  bool fromCampus = false;
  DateTime? departureDate;

  /// Return a formatted string date to allow the user to know
  /// when they want to depart.
  /// ex: "2022-03-29"
  String getFormattedDepartureDate() {
    String formattedDate = departureDate != null ? departureDate!.toIso8601String().split('T').first : 'Departure Date';
    return formattedDate;
  }

  /// Update the `toCampus` choice to true and notify listeners.
  void toCampusChoice() {
    toCampus = !toCampus;
    notifyListeners();
  }

  /// Update the `toCampus` choice to false and notify listeners.
  void fromCampusChoice() {
    fromCampus = !fromCampus;
    notifyListeners();
  }

  /// Update the `departureTime` to input and notify listeners.
  void updateDepartureDate(DateTime? departureDate) {
    this.departureDate = departureDate;
    notifyListeners();
  }

  /// Reset all attributes of the FilterRideViewModel
  void resetAll() {
    toCampus = false;
    fromCampus = false;
    departureDate = null;
    notifyListeners();
  }
}
