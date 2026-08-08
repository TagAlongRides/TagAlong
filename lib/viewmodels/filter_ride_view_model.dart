import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagalong/util/ride_filters.dart';

/// A ViewModel that maintains the state and functionality
/// of the "Filter Ride" flow (ModalBottomSheet).
///
/// This is the working copy the sheet edits; it is only handed to the
/// [RideBoardViewModel] when the user taps "Filter".
class FilterRideViewModel with ChangeNotifier {
  static final DateFormat _dateFormat = DateFormat('MMM d, y');

  bool toCampus = true; // Defaults to true on Modal sheet
  DateTimeRange? departureRange;
  bool day = false;
  bool night = false;
  String? destination;

  /// Options for the Point B dropdown, refreshed whenever the direction
  /// changes. Empty until [setDestinationOptions] is called.
  List<String> destinationOptions = [];

  /// Whether the destination options are being fetched.
  bool loadingDestinations = false;

  /// Return a formatted string date to allow the user to know
  /// when they want to depart.
  /// ex: "Mar 29, 2022" or "Mar 29, 2022 - Apr 2, 2022"
  String getFormattedDepartureDate() {
    if (departureRange == null) {
      return 'Departure Date';
    }
    final start = _dateFormat.format(departureRange!.start);
    if (DateUtils.isSameDay(departureRange!.start, departureRange!.end)) {
      return start;
    }
    return '$start - ${_dateFormat.format(departureRange!.end)}';
  }

  /// Update the `toCampus` choice to true and notify listeners.
  ///
  /// The destination options depend on the direction, so any previously
  /// selected destination is dropped.
  void toCampusChoice() {
    if (toCampus) return;
    toCampus = true;
    destination = null;
    destinationOptions = [];
    notifyListeners();
  }

  /// Update the `toCampus` choice to false and notify listeners.
  void fromCampusChoice() {
    if (!toCampus) return;
    toCampus = false;
    destination = null;
    destinationOptions = [];
    notifyListeners();
  }

  /// Update the departure date or date range and notify listeners.
  void updateDepartureRange(DateTimeRange? range) {
    departureRange = range;
    notifyListeners();
  }

  /// Toggle the "day" (6am - 5:59pm) time-of-day filter.
  void toggleDay() {
    day = !day;
    notifyListeners();
  }

  /// Toggle the "night" (6pm - 5:59am) time-of-day filter.
  void toggleNight() {
    night = !night;
    notifyListeners();
  }

  void updateDestination(String? destination) {
    this.destination = destination;
    notifyListeners();
  }

  void setLoadingDestinations(bool loading) {
    loadingDestinations = loading;
    notifyListeners();
  }

  void setDestinationOptions(List<String> options) {
    destinationOptions = options;
    // Drop a selection that is no longer on offer.
    if (destination != null && !options.contains(destination)) {
      destination = null;
    }
    loadingDestinations = false;
    notifyListeners();
  }

  /// Reset all attributes of the FilterRideViewModel
  void resetAll() {
    toCampus = true;
    departureRange = null;
    day = false;
    night = false;
    destination = null;
    destinationOptions = [];
    notifyListeners();
  }

  /// Snapshot of the current selections, ready to hand to the Ride Board.
  RideFilters toRideFilters() {
    return RideFilters(
      toCampus: toCampus,
      departureDateStart: departureRange?.start,
      // Include everything up to the end of the last selected day.
      departureDateEnd: departureRange == null
          ? null
          : DateTime(
              departureRange!.end.year,
              departureRange!.end.month,
              departureRange!.end.day,
              23,
              59,
              59,
            ),
      day: day,
      night: night,
      destination: destination,
    );
  }

  /// Rehydrates the sheet from the filters currently applied to the board, so
  /// re-opening it shows what the user last chose.
  void loadFrom(RideFilters filters) {
    toCampus = filters.toCampus ?? true;
    departureRange = filters.departureDateStart == null || filters.departureDateEnd == null
        ? null
        : DateTimeRange(start: filters.departureDateStart!, end: filters.departureDateEnd!);
    day = filters.day;
    night = filters.night;
    destination = filters.destination;
  }
}
