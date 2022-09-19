// To parse this JSON data, do
//
//     final rodeModel = rodeModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ride_repo/src/enum/ride_status_enum.dart';

RideModel rodeModelFromJson(String str) => RideModel.fromJson(json.decode(str));

String rodeModelToJson(RideModel data) => json.encode(data.toJson());

class RideModel {
  RideModel({
    required this.rideId,
    required this.driverId,
    required this.notes,
    this.riderIds = const [],
    this.rideBookingIds = const [],
    required this.pickupLocation,
    required this.university,
    required this.driverFullName,
    required this.noBags,
    required this.createdAt,
    required this.toCampus,
    required this.vehicle,
    required this.departureTimeOfDay,
    required this.driverProfilePictureUrl,
    required this.price,
    required this.departureDateTime,
    required this.noPassengers,
    required this.remainingSeats,
    required this.vaccinationCard,
    required this.dropoffLocation,
    required this.status,
    required this.stripeAccountId,
    this.updatedAt,
  });

  /// [docId] from firebase collection
  String? docId;

  final String rideId;
  final String driverId;
  final String notes;
  final List<String> riderIds;
  final List<String> rideBookingIds;
  final Location pickupLocation;
  final String university;
  final String driverFullName;
  final int noBags;
  final dynamic createdAt;
  final bool toCampus;
  final Vehicle vehicle;
  final String departureTimeOfDay;
  final String driverProfilePictureUrl;
  final int price;
  final DateTime departureDateTime;
  final int noPassengers;
  int remainingSeats;
  final bool vaccinationCard;
  final Location dropoffLocation;
  RideStatus status;
  final String stripeAccountId;
  DateTime? updatedAt;

  factory RideModel.fromJson(Map<String, dynamic> json) => RideModel(
        rideId: json["ride_id"],
        driverId: json["driver_id"],
        notes: json["notes"],
        riderIds: List<String>.from(json["rider_ids"] ?? [].map((x) => x)),
        rideBookingIds: List<String>.from(json["ride_booking_ids"] ?? [].map((x) => x)),
        pickupLocation: Location.fromJson(json["pickup_location"]),
        university: json["university"],
        driverFullName: json["driver_full_name"],
        noBags: json["no_bags"],
        createdAt: json["created_at"],
        toCampus: json["to_campus"],
        vehicle: Vehicle.fromJson(json["vehicle"]),
        departureTimeOfDay: json["departure_time_of_day"],
        driverProfilePictureUrl: json["driver_profile_picture_url"],
        price: json["price"],
        departureDateTime: (json["departure_date_time"] as Timestamp).toDate(),
        noPassengers: json["no_passengers"],
        remainingSeats: json["remaining_seats"],
        vaccinationCard: json["vaccination_card"],
        dropoffLocation: Location.fromJson(json["dropoff_location"]),
        status: RideStatus.values.byName(json["status"].toString().toLowerCase()),
        stripeAccountId: json["stripe_account_id"] ?? '',
        updatedAt: json["updated_at"] == null ? null : (json["updated_at"] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        "ride_id": rideId,
        "driver_id": driverId,
        "notes": notes,
        "rider_ids": List<String>.from(riderIds.map((x) => x)),
        "ride_booking_ids": List<String>.from(rideBookingIds.map((x) => x)),
        "pickup_location": pickupLocation.toJson(),
        "university": university,
        "driver_full_name": driverFullName,
        "no_bags": noBags,
        "created_at": createdAt,
        "to_campus": toCampus,
        "vehicle": vehicle.toJson(),
        "departure_time_of_day": departureTimeOfDay,
        "driver_profile_picture_url": driverProfilePictureUrl,
        "price": price,
        "departure_date_time": departureDateTime,
        "no_passengers": noPassengers,
        "remaining_seats": remainingSeats,
        "vaccination_card": vaccinationCard,
        "dropoff_location": dropoffLocation.toJson(),
        "status": status.name.toLowerCase(),
        "stripe_account_id": stripeAccountId,
        "updated_at": updatedAt,
      };

  /// Returns a [TimeOfDay] instance given a stringified TimeOfDay
  static TimeOfDay timeOfDayFromString(String str) {
    return TimeOfDay(hour: int.parse(str.split(':')[0]), minute: int.parse(str.split(':')[1].substring(0, 2)));
  }

  /// Returns a string First Name and last initial for a driver.
  ///
  /// eg. Steven P.
  String getFirstNameAndInitial() {
    return "${driverFullName.split(" ")[0]} ${driverFullName.split(" ")[1][0]}.";
  }
}

class Location {
  Location({
    required this.zip,
    required this.address,
    required this.locationImageUrl,
    required this.city,
    this.label,
    required this.state,
  });

  final String zip;
  final String address;
  final dynamic locationImageUrl;
  final String city;
  final String? label;
  final String state;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        zip: json["zip"],
        address: json["address"],
        locationImageUrl: json["location_image_url"],
        city: json["city"],
        label: json["label"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "zip": zip,
        "address": address,
        "location_image_url": locationImageUrl,
        "city": city,
        "label": label,
        "state": state,
      };
}

class Vehicle {
  Vehicle({
    required this.color,
    // required this.year,
    required this.createdAt,
    required this.model,
    required this.vehicleId,
    required this.make,
  });

  final String color;
  // final String year;
  final dynamic createdAt;
  final String model;
  final String vehicleId;
  final String make;

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        color: json["color"],
        // year: json["year"],
        createdAt: json["created_at"],
        model: json["model"],
        vehicleId: json["vehicle_id"],
        make: json["make"],
      );

  Map<String, dynamic> toJson() => {
        "color": color,
        // "year": year,
        "created_at": createdAt,
        "model": model,
        "vehicle_id": vehicleId,
        "make": make,
      };
}
