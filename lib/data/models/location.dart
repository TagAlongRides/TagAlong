
import 'package:tagalong/data/models/ta_data_model.dart';

/// [Location] data model
///
/// See https://pe.usps.com/businessmail101?ViewName=DeliveryAddress
/// as to what the U.S Postal Office considers a complete address as well as
/// how to format it.
class Location implements TADataModel {
  String address;
  String city;
  String zip;
  String? label;
  String? locationImageUrl;

  // Constructor
  Location({
    required this.address,
    required this.city,
    required this.zip,
    this.label=null,
    this.locationImageUrl=null
  });

  /// A factory constructor that will convert a Map<String, dynamic> into
  /// a [Location] instance.
  factory Location.fromJson(Map<String, dynamic> json) {
    var address = json['address'] as String?;
    if (address == null) {
      throw UnsupportedError('Invalid - address is $address');
    }
    var city = json['city'] as String?;
    if (city == null) {
      throw UnsupportedError('Invalid - city is $city');
    }
    var zip = json['zip'] as String?;
    if (zip == null) {
      throw UnsupportedError('Invalid - zip is $zip');
    }
    var label = json['label'] as String?;
    var locationImageUrl = json['location_image_url'] as String?;

    return Location(
      address: address,
      city: city,
      zip: zip,
      label: label,
      locationImageUrl: locationImageUrl
    );
  }

  /// Converts this [Location] instance to a JSON Map<String, dynamic> structure.
  @override
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'zip': zip,
      'label': label,
      'location_image_url': locationImageUrl
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }



}