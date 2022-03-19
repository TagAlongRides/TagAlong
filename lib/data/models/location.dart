
import 'package:tagalong/data/models/ta_data_model.dart';

/// [Location] data model
class Location implements TADataModel {
  String pickupAddress;
  String dropoffAddress;
  String city;
  String zip;
  String? locationImageUrl;

  // Constructor
  Location({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.city,
    required this.zip,
    this.locationImageUrl=null
  });

  /// A factory constructor that will convert a Map<String, dynamic> into
  /// a [Location] instance.
  factory Location.fromJson(Map<String, dynamic> json) {
    var pickupAddress = json['pickup_address'] as String?;
    if (pickupAddress == null) {
      throw UnsupportedError('Invalid - pickupAddress is $pickupAddress');
    }
    var dropoffAddress = json['dropoff_address'] as String?;
    if (dropoffAddress == null) {
      throw UnsupportedError('Invalid - dropoffAddress is $dropoffAddress');
    }
    var city = json['city'] as String?;
    if (city == null) {
      throw UnsupportedError('Invalid - city is $city');
    }
    var zip = json['zip'] as String?;
    if (zip == null) {
      throw UnsupportedError('Invalid - zip is $zip');
    }
    var locationImageUrl = json['location_image_url'] as String?;

    return Location(
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      city: city,
      zip: zip,
      locationImageUrl: locationImageUrl
    );
  }

  /// Converts this [Location] instance to a JSON Map<String, dynamic> structure.
  @override
  Map<String, dynamic> toJson() {
    return {
      'pickp_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'city': city,
      'zip': zip,
      'location_image_url': locationImageUrl
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }



}