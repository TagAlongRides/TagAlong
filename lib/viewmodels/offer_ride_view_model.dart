import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/data/globals.dart';
import 'package:flutter/material.dart';
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/util/ride_status.dart';

/// A ViewModel that maintains the state of the "Offer Ride" user flow.
class OfferRideViewModel with ChangeNotifier {

  // Firebase Services
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();

  // Constants for range of passengers and bags
  List<int> PASSENGERS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<int> BAGS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // User-inputted [Ride] attributes
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

  /// Will create a new [Ride] instance and upload the [Ride]
  /// to the "rides" collection in Firestore.
  /// TODO: Find solution to nested ViewModels so we can get TagAlongUser
  /// info, such as university W/O another read!
  Future<bool> createNewRide() async {
    // Create a [Ride] instance
    final String ride_id = uuid.v4();
    Ride ride = Ride(
      createdAt: DateTime.now(),
      rideId: ride_id,
      driverId: authService.getUid()!,
      university: Institution.VIRGINIA_TECH,
      status: RideStatus.SCHEDULED,
      toCampus: toCampus,
      pickupLocation: pickupLocation!,
      dropoffLocation: dropoffLocation!,
      locationCity: locationCity!,
      locationZip: locationZip!,
      departureDateTime: departureDateTime!,
      departureTimeOfDay: departureTimeOfDay!,
      noPassengers: noPassengers,
      noBags: noBags,
      price: price,
      vaccinationCard: vaccinationCard,
      notes: notes
    );

    // Get corresponding [Map] data from [Ride]
    Map<String, dynamic> map = ride.toJson();

    // Push to Firebase with our specific RideID, [ride_id]
    await databaseService.rides.doc(ride_id).set(map);

    // Reset the [OfferRideViewModel]
    resetAll();
    return true;
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
      'notes': notes,
    };
    // print('TagAlongUserViewModel: ${tagAlongUserViewModel.tagAlongUser}');
    return map.toString();
  }

}