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

  /// Builds a [RideModel] from a Firestore document.
  ///
  /// Throws [UnsupportedError] naming the offending field when a required one
  /// is missing or the wrong type, so a malformed ride is diagnosable instead
  /// of surfacing as an opaque cast failure while the Ride Board builds.
  factory RideModel.fromJson(Map<String, dynamic> json) => RideModel(
        rideId: _require<String>(json, "ride_id"),
        driverId: _require<String>(json, "driver_id"),
        notes: json["notes"] ?? "",
        riderIds: List<String>.from(json["rider_ids"] ?? const []),
        rideBookingIds: List<String>.from(json["ride_booking_ids"] ?? const []),
        pickupLocation: Location.fromJson(_require<Map<String, dynamic>>(json, "pickup_location")),
        university: _require<String>(json, "university"),
        driverFullName: _require<String>(json, "driver_full_name"),
        noBags: _require<int>(json, "no_bags"),
        createdAt: _require<Object>(json, "created_at"),
        toCampus: _require<bool>(json, "to_campus"),
        vehicle: Vehicle.fromJson(_require<Map<String, dynamic>>(json, "vehicle")),
        departureTimeOfDay: _require<String>(json, "departure_time_of_day"),
        driverProfilePictureUrl: json["driver_profile_picture_url"] ?? "",
        price: _require<int>(json, "price"),
        departureDateTime: _require<Timestamp>(json, "departure_date_time").toDate(),
        noPassengers: _require<int>(json, "no_passengers"),
        // A ride stored without a seat count has had nobody book it yet, so
        // every seat the driver offered is still free.
        remainingSeats: json["remaining_seats"] ?? _require<int>(json, "no_passengers"),
        vaccinationCard: json["vaccination_card"] ?? false,
        dropoffLocation: Location.fromJson(_require<Map<String, dynamic>>(json, "dropoff_location")),
        status: RideStatus.values.byName(_require<String>(json, "status").toLowerCase()),
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

  /// Reads [field] from [json], or throws naming what was wrong with it.
  static T _require<T>(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! T) {
      throw UnsupportedError('Invalid ride - $field is $value');
    }
    return value;
  }

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

  /// Builds a [Location] from a Firestore document.
  ///
  /// Throws [UnsupportedError] naming the offending field when a required one
  /// is missing, rather than letting a raw cast fail somewhere further up.
  factory Location.fromJson(Map<String, dynamic> json) => Location(
        zip: _required(json, "zip"),
        address: _required(json, "address"),
        locationImageUrl: json["location_image_url"],
        city: _required(json, "city"),
        label: json["label"],
        // Not every stored location carries a state.
        state: json["state"] ?? "",
      );

  static String _required(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String) {
      throw UnsupportedError('Invalid location - $field is $value');
    }
    return value;
  }

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

  /// Builds a [Vehicle] from a Firestore document, naming any missing field.
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final createdAt = json["created_at"];
    if (createdAt == null) {
      throw UnsupportedError('Invalid vehicle - created_at is null');
    }
    return Vehicle(
      color: _required(json, "color"),
      // year: json["year"],
      createdAt: createdAt,
      model: _required(json, "model"),
      vehicleId: _required(json, "vehicle_id"),
      make: _required(json, "make"),
    );
  }

  static String _required(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String) {
      throw UnsupportedError('Invalid vehicle - $field is $value');
    }
    return value;
  }

  Map<String, dynamic> toJson() => {
        "color": color,
        // "year": year,
        "created_at": createdAt,
        "model": model,
        "vehicle_id": vehicleId,
        "make": make,
      };
}
