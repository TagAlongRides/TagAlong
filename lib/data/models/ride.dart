import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tagalong/data/models/ta_data_model.dart';
import 'package:tagalong/util/user_data.dart';


/// [Ride] data model.
class Ride implements TADataModel {

  final DateTime createdAt;
  final String rideId;          // UUID
  final String driverId;
  final String university;
  String status;
  String pickupLocation;
  String dropoffLocation;
  String locationCity;
  String locationZip;
  String notes;
  int noPassengers;
  int noBags;
  int price;
  bool vaccinationCard;
  bool toCampus;
  // May be able to combine these in the future for "efficiency", but
  // this allows a quick way for us to disable "TimeOfDay" button with
  // deliberate "Date" to leave chosen
  DateTime departureDateTime;
  TimeOfDay departureTimeOfDay;

  Ride({
    required this.createdAt,
    required this.rideId,
    required this.driverId,
    required this.university,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.locationCity,
    required this.locationZip,
    required this.notes,
    required this.noPassengers,
    required this.noBags,
    required this.price,
    required this.vaccinationCard,
    required this.toCampus,
    required this.departureDateTime,
    required this.departureTimeOfDay
  });

  /// A Map<String, dynamic> into a [Ride] instance.
  ///
  /// Assumes that [json] data is always from Firebase, therefore
  /// `created_at` may be a [Timestamp] or [DateTime],
  /// since Firebase store [DateTime] as [TimeStamp]
  factory Ride.fromJson(Map<String, dynamic> json) {
    var createdAt = json['created_at'];
    if (createdAt == null) {
      throw UnsupportedError('Invalid - createdAt is $createdAt');
    }
    else if (createdAt is Timestamp) {
      createdAt = createdAt.toDate();
    }
    var rideId = json['ride_id'] as String?;
    if (rideId == null) {
      throw UnsupportedError('Invalid - rideId is $rideId');
    }
    var driverId = json['driver_id'] as String?;
    if (driverId == null) {
      throw UnsupportedError('Invalid - driverId is $driverId');
    }
    var university = json['university'] as String?;
    if (university == null) {
      throw UnsupportedError('Invalid - university is $university');
    }
    var status = json['status'] as String?;
    if (status == null) {
      throw UnsupportedError('Invalid - status is $status');
    }
    var pickupLocation = json['pickup_location'] as String?;
    if (pickupLocation == null) {
      throw UnsupportedError('Invalid - pickupLocation is $pickupLocation');
    }
    var dropoffLocation = json['dropoff_location'] as String?;
    if (dropoffLocation == null) {
      throw UnsupportedError('Invalid - dropoffLocation is $dropoffLocation');
    }
    var locationCity = json['locationCity'] as String?;
    if (locationCity == null) {
      throw UnsupportedError('Invalid - locationCity is $locationCity');
    }
    var locationZip = json['location_zip'] as String?;
    if (locationZip == null) {
      throw UnsupportedError('Invalid - locationZip is $locationZip');
    }
    var notes = json['notes'] as String?;
    if (notes == null) {
      throw UnsupportedError('Invalid - notes is $notes');
    }
    var noPassengers = json['no_passengers'] as int?;
    if (noPassengers == null) {
      throw UnsupportedError('Invalid - noPassengers is $noPassengers');
    }
    var noBags = json['no_bags'] as int?;
    if (noBags == null) {
      throw UnsupportedError('Invalid - noBags is $noBags');
    }
    var price = json['price'] as int?;
    if (price == null) {
      throw UnsupportedError('Invalid - price is $price');
    }
    var vaccinationCard = json['vaccination_card'] as bool?;
    if (vaccinationCard == null) {
      throw UnsupportedError('Invalid - vaccinationCard is $vaccinationCard');
    }
    var toCampus = json['to_campus'] as bool?;
    if (toCampus == null) {
      throw UnsupportedError('Invalid - toCampus is $toCampus');
    }
    var departureDateTime = json['departure_date_time'];
    if (departureDateTime == null) {
      throw UnsupportedError('Invalid - departureDateTime is $departureDateTime');
    }
    else if (departureDateTime is Timestamp) {
      departureDateTime = departureDateTime.toDate();
    }
    var departureTimeOfDay = json['departure_time_of_day'];
    if (departureTimeOfDay == null) {
      throw UnsupportedError('Invalid - departureTimeOfDay is $departureTimeOfDay');
    }
    else if (departureTimeOfDay is Timestamp) {
      departureTimeOfDay = TimeOfDay.fromDateTime(departureTimeOfDay.toDate());
    }

    return Ride(
      createdAt: createdAt,
      rideId: rideId,
      driverId: driverId,
      university: university,
      status: status,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      locationCity: locationCity,
      locationZip: locationZip,
      notes: notes,
      noPassengers: noPassengers,
      noBags: noBags,
      price: price,
      vaccinationCard: vaccinationCard,
      toCampus: toCampus,
      departureDateTime: departureDateTime,
      departureTimeOfDay: departureTimeOfDay
    );

  }

  /// A [Ride] instance into a Map<String, dynamic>
  @override
  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'ride_id': rideId,
      'driver_id': driverId,
      'university': university,
      'status': status,
      'pickup_location': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'location_city': locationCity,
      'location_zip': locationZip,
      'notes': notes,
      'no_passengers': noPassengers,
      'no_bags': noBags,
      'price': price,
      'vaccination_card': vaccinationCard,
      'to_campus': toCampus,
      'departure_date_time': departureDateTime,
      'departure_time_of_day': departureTimeOfDay
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }


}