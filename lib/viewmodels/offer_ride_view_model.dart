import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A ViewModel that maintains the state of the "Offer Ride" user flow.
class OfferRideViewModel with ChangeNotifier {

  List<int> PASSENGERS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<int> BAGS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  bool toCampus = true;         // Default
  String? pickupLocation;
  String? dropoffLocation;
  String? locationCity;
  String? locationZip;
  DateTime? departureDateTime;
  TimeOfDay? departureTimeOfDay;
  int noPassengers = 2;         // Default
  int noBags = 2;               // Default
  int price = 20;               // Default
  bool vaccinationCard = true;  // Default
  String notes = '';            // Default

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

  void updateLocationCity(String? locationCity) {
    this.locationCity = locationCity!;
    notifyListeners();
  }

  void updateLocationZip(String? locationZip) {
    this.locationZip = locationZip!;
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

  void incrementNoPassengers() {
    if (noPassengers < 10) {
      noPassengers += 1;
      notifyListeners();
    }
  }

  void decrementNoPassengers() {
    if (noPassengers > 1) {
      noPassengers -= 1;
      notifyListeners();
    }
  }

  void incrementNoBags() {
    if (noBags < 10) {
      noBags += 1;
      notifyListeners();
    }
  }

  void decrementNoBags() {
    if (noBags > 1) {
      noBags -= 1;
      notifyListeners();
    }
  }

  void incrementPrice() {
    if (price < 500) {
      price += 1;
      notifyListeners();
    }
  }

  void decrementPrice() {
    if (price > 5){
      price -= 1;
      notifyListeners();
    }
  }

  void updateVaccinationCard() {
    vaccinationCard = !vaccinationCard;
    notifyListeners();
  }

  void updateNotes(String notes) {
    this.notes = notes;
    notifyListeners();
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

  void resetCityAndZip() {
    locationCity = null;
    locationZip = null;
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

  void resetVaccinationCard() {
    vaccinationCard = true;
  }

  void resetAll() {
    toCampus = true;          // Default
    pickupLocation = null;
    dropoffLocation = null;
    departureDateTime = null;
    departureTimeOfDay = null;
    noPassengers = 2;         // Default
    noBags = 2;               // Default
    price = 20;               // Default
    vaccinationCard = true;   // Default
    notes = '';               // Default
  }

  @override
  String toString() {
    Map<String, dynamic> map = {
      'toCampus': toCampus,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'locationCity': locationCity,
      'locationZip': locationZip,
      'departureDateTime': departureDateTime,
      'departureTimeOfDay': departureTimeOfDay,
      'noPassengers': noPassengers,
      'noBags': noBags,
      'price': price,
      'vaccinationCard': vaccinationCard,
      'notes': notes
    };
    return map.toString();
  }

}