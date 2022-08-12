// import 'package:tagalong/data/models/ta_data_model.dart';

// /// [Location] data model
// ///
// /// See https://pe.usps.com/businessmail101?ViewName=DeliveryAddress
// /// as to what the U.S Postal Office considers a complete address as well as
// /// how to format it.
// class Location implements TADataModel {
//   String address;     // 1234 Fake Street
//   String city;        // Chantilly
//   String state;       // VA
//   String zip;         // 202022
//   String? label;      // <city> OR University "place"
//   String? locationImageUrl;

//   // Constructor
//   Location(
//       {required this.address,
//       required this.city,
//       required this.zip,
//       required this.state,
//       this.label = null,
//       this.locationImageUrl = null});

//   /// A factory constructor that will convert a Map<String, dynamic> into
//   /// a [Location] instance.
//   factory Location.fromJson(Map<String, dynamic> json) {
//     var address = json['address'] as String?;
//     if (address == null) {
//       throw UnsupportedError('Invalid - address is $address');
//     }
//     var city = json['city'] as String?;
//     if (city == null) {
//       throw UnsupportedError('Invalid - city is $city');
//     }
//     var state = json['state'] as String?;
//     if (state == null) {
//       throw UnsupportedError('Invalid - state is $state');
//     }
//     var zip = json['zip'] as String?;
//     if (zip == null) {
//       throw UnsupportedError('Invalid - zip is $zip');
//     }
//     var label = json['label'] as String?;
//     var locationImageUrl = json['location_image_url'] as String?;

//     return Location(
//         address: address,
//         city: city,
//         state: state,
//         zip: zip,
//         label: label,
//         locationImageUrl: locationImageUrl);
//   }

//   /// Converts this [Location] instance to a JSON Map<String, dynamic> structure.
//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'address': address,
//       'city': city,
//       'state': state,
//       'zip': zip,
//       'label': label,
//       'location_image_url': locationImageUrl
//     };
//   }

//   /// Returns a U.S Postal formatted version of the Location
//   @override
//   String toString() {
//     return "$address $city, $state $zip";
//   }
// }
