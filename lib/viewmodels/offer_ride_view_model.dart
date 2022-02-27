import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OfferRideViewModel extends ChangeNotifier {

  List<int> PASSENGERS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<int> BAGS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  bool toCampus = true;         // Default
  String? pickupLocation;
  String? dropoffLocation;
  DateTime? departureDateTime;
  TimeOfDay? departureTimeOfDay;
  int noPassengers = 2;         // Default
  int noBags = 2;               // Default
  int price = 20;               // Default

  // TODO: Update
  void toCampusChoice() {
    toCampus = true;
    notifyListeners();
  }

  void fromCampusChoice() {
    toCampus = false;
    notifyListeners();
  }

  void updatePickupLocation(String? pickUpLocation) {
    pickupLocation = pickUpLocation!;
    notifyListeners();
  }

  void updateDropoffLocation(String? dropOffLocation) {
    dropoffLocation = dropOffLocation!;
    notifyListeners();
  }

  void updateDepartureDateTime(DateTime? departureDateTime) {
    this.departureDateTime = departureDateTime;
    notifyListeners();
  }

  void updateDepartureTimeOfDay(TimeOfDay? departureTimeOfDay) {
    this.departureTimeOfDay = departureTimeOfDay;
    notifyListeners();
  }

  void updateNoPassengers(int noPassengers) {
    this.noPassengers = noPassengers;
    notifyListeners();
  }

  void updateNoBags(int noBags) {
    this.noBags = noBags;
    notifyListeners();
  }

  void incrementPrice() {
    price += 1;
    notifyListeners();
  }

  void decrementPrice() {
    if (price > 0){
      price -= 1;
      notifyListeners();
    }
  }

  void resetCampusChoice() {
    toCampus = true;
  }

  void resetPickupLocation() {
    pickupLocation = null;
  }

  void resetDropoffLocation() {
    dropoffLocation = null;
  }

  void resetDepartureDateTime() {
    departureDateTime = null;
  }

  void resetDepartureTimeOfDay() {
    departureTimeOfDay = null;
  }

  void resetNoPassengers() {
    noPassengers = 2;
  }

  void resetNoBags() {
    noBags = 2;
  }

  void resetPrice() {
    price = 20;
  }

  @override
  String toString() {
    Map<String, dynamic> map = {
      'toCampus': toCampus,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'departureDateTime': departureDateTime,
      'departureTimeOfDay': departureTimeOfDay,
      'noPassengers': noPassengers,
      'noBags': noBags,
      'price': price
    };
    return map.toString();
  }

}