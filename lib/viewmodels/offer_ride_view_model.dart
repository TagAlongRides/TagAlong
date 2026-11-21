import 'package:flutter/material.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/data/globals.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/data_service.dart';
import 'package:tagalong/services/places_service.dart';
import 'package:tagalong/util/user_data.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

import '../util/university_locations.dart';

/// A ViewModel that maintains the state and functionality
/// of the "Offer Ride" user flow.
class OfferRideViewModel with ChangeNotifier {
  OfferRideViewModel({required this.tagAlongUserViewModel});

  TagAlongUserViewModel tagAlongUserViewModel;

  // Firebase Services
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();

  // Constants for range of passengers and bags
  List<int> PASSENGERS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<int> BAGS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // User-inputted [Ride] attributes
  bool toCampus = true; // Default

  /// The campus end of the ride: a [VirginiaTechLocation] name.
  ///
  /// It is the dropoff on a ride to campus and the pickup on one from campus,
  /// so flipping [toCampus] keeps both ends the driver already chose.
  String? campusSpot;

  /// The off-campus end, as found on Google Maps.
  ResolvedPlace? offCampusPlace;
  /// The day the driver picked (any time on it; only the date is used).
  DateTime? departureDate;

  /// The time of day the driver picked, on their own clock.
  TimeOfDay? departureTime;

  /// The moment the ride leaves, once both a date and a time are chosen.
  ///
  /// Built in the device's local zone, so it is the instant the driver means.
  DateTime? get departureDateTime {
    final date = departureDate;
    final time = departureTime;
    if (date == null || time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
  int noPassengers = 2; // Default
  int noBags = 2; // Default
  int price = 20; // Default
  bool vaccinationCard = true; // Default
  String notes = ''; // Default

  void toCampusChoice() {
    toCampus = true;
    print('TagAlongUserViewModel: ${tagAlongUserViewModel.tagAlongUser?.toString()}');
    notifyListeners();
  }

  void fromCampusChoice() {
    toCampus = false;
    notifyListeners();
  }

  void updateCampusSpot(String? spot) {
    campusSpot = spot;
    notifyListeners();
  }

  void updateOffCampusPlace(ResolvedPlace? place) {
    offCampusPlace = place;
    notifyListeners();
  }

  void updateDepartureDate(DateTime? departureDate) {
    this.departureDate = departureDate;
    notifyListeners();
  }

  void updateDepartureTime(TimeOfDay? departureTime) {
    this.departureTime = departureTime;
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
    if (price > 5) {
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


  void resetDepartureDate() {
    departureDate = null;
  }

  void resetDepartureTime() {
    departureTime = null;
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
    toCampus = true; // Default
    campusSpot = null;
    offCampusPlace = null;
    departureDate = null;
    departureTime = null;
    noPassengers = 2; // Default
    noBags = 2; // Default
    price = 20; // Default
    vaccinationCard = true; // Default
    notes = ''; // Default
  }

  /// Will create a new [RideModel] instance and upload the [RideModel]
  /// to the "rides" collection in Firestore.
  Future<bool> createNewRide() async {
    late RideModel ride;

    // The campus end carries its spot name as a label; the off-campus end is
    // whatever Google Maps resolved the driver's search to.
    final campus = VirginiaTechLocation.transformAddressIntoLocation(
        address: VirginiaTechLocation.mappings[campusSpot!]!, label: campusSpot);
    final offCampus = offCampusPlace!.location;
    final Location pickupLocation = toCampus ? offCampus : campus;
    final Location dropoffLocation = toCampus ? campus : offCampus;

    // Create a [Ride] instance
    final String rideId = uuid.v4();
    final driverFullName =
        tagAlongUserViewModel.tagAlongUser!.firstName + " " + tagAlongUserViewModel.tagAlongUser!.lastName;
    ride = RideModel(
      createdAt: DateTime.now(),
      rideId: rideId,
      driverId: tagAlongUserViewModel.tagAlongUser!.id,
      // The ride belongs to the driver's school, which is what the Ride Board
      // filters on (Milestone 2, §9.2.2).
      university: tagAlongUserViewModel.tagAlongUser!.institution,
      status: RideStatus.scheduled,
      toCampus: toCampus,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      departure: Departure.local(departureDateTime!),
      noPassengers: noPassengers,
      remainingSeats: noPassengers, // Initialize this to be the total number of seats driver is offering
      noBags: noBags,
      price: price,
      vaccinationCard: vaccinationCard,
      notes: notes.trim(),
      driverFullName: driverFullName,
      driverProfilePictureUrl: tagAlongUserViewModel.tagAlongUser!.profilePictureUrl,
      riderIds: [],
      rideBookingIds: [],
      vehicle: tagAlongUserViewModel.tagAlongUser!.driverData!.vehicle,
      stripeAccountId: tagAlongUserViewModel.tagAlongUser!.driverData!.stripeAccountId!,
    );

    // Get corresponding [Map] data from [Ride]
    Map<String, dynamic> map = ride.toJson();

    // Push to Firebase with our specific RideID, [ride_id]
    await databaseService.rides.doc(rideId).set(map);

    // Reset the [OfferRideViewModel]
    resetAll();
    notifyListeners();
    return true;
  }

  // TODO: 4/2/22 Outdated
  @override
  String toString() {
    Map<String, dynamic> map = {
      'toCampus': toCampus,
      'campusSpot': campusSpot,
      'offCampusPlace': offCampusPlace?.formattedAddress,
      'departureDateTime': departureDateTime,
      'noPassengers': noPassengers,
      // 'remainingSeats': remainingSeats,
      'noBags': noBags,
      'price': price,
      'vaccinationCard': vaccinationCard,
      'notes': notes,
    };
    return map.toString();
  }
}

/// A ViewModel that represents a subset of the "Offer Ride" user flow.
/// This is used for the last step of actually uploading the [RideModel] to the
/// "rides" Firestore Collection.
/// This is solely separated from [OfferRideViewModel] because we want to
/// alert the [RideBoard] to rebuild when the user uploads a ride,
/// not everytime an update occurs in the "Offer Ride" flow.
class UploadRideViewModel with ChangeNotifier {
  void uploadedRide() {
    notifyListeners();
  }
}
