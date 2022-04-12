import 'package:tagalong/data/models/location.dart';

/// String Enums for university locations.
/// Note: This will most likely change in the future because if we wanted to
///       update this list, user would need to update the app; perhaps
///       better to make this available via an RESTful API in future.
class VirginiaTechLocation {
  static const String BURRUSS_HALL = 'Burruss Hall';
  static const String NEWMAN_LIBRARY = 'Newman Library';
  static const String SQUIRES_CENTER = 'Squires Student Center';
  static const String JOHNSTON_CENTER = 'Johnston Student Center';
  static const String TORGERSEN_BRIDGE = 'Torgersen Bridge';
  static const String GRADUATE_CENTER = 'Graduate Life Center';
  static const String OWENS_DINING_HALL = 'Owens Dining Hall';
  static const String D2_DINING_HALL = 'D2 Dining Hall';
  static const String TURNER_PLACE_DINING_HALL = 'Turning Place Dining Hall';
  static const String WEST_END_DINING_HALL = 'West End Dining Hall';
  static const String PRITCHARD_HALL = 'Pritchard Hall';
  static const String HOGE_HALL = 'Hoge Hall';
  static const String SLUSHER_HALL = 'Slusher Hall';
  static const String WEST_AJ = 'West AJ';
  static const String EAST_AJ = 'East AJ';

  /// A mapping of the location "label" to the full address, in U.S specific format
  static const Map<String, String> mappings = {
    BURRUSS_HALL: '800 Drillfield Dr, Blacksburg, VA 24061',
    NEWMAN_LIBRARY: '560 Drillfield Dr, Blacksburg, VA 24061',
    SQUIRES_CENTER: '290 College Ave, Blacksburg, VA 24060',
    JOHNSTON_CENTER: '920 W Campus Dr, Blacksburg, VA 24060',
    TORGERSEN_BRIDGE: '620 Drillfield Dr, Blacksburg, VA 24061',
    GRADUATE_CENTER: '155 Otey St, Blacksburg, VA 24060',
    OWENS_DINING_HALL: 'Owens Hall Kent St, Blacksburg, VA 24061',
    D2_DINING_HALL: '285 Ag-Quad Ln, Blacksburg, VA 24060',
    TURNER_PLACE_DINING_HALL: '409 Old Turner St, Blacksburg, VA 24060',
    WEST_END_DINING_HALL: '770 Washington St SW, Blacksburg, VA 24060',
    PRITCHARD_HALL: 'Washington St SW, Blacksburg, VA 24060',
    HOGE_HALL: '570 Washington St SW, Blacksburg, VA 24061',
    SLUSHER_HALL: '201 Ag-Quad Ln, Blacksburg, VA 24060',
    WEST_AJ: '720 Washington St SW, Blacksburg, VA 24061',
    EAST_AJ: '700 Washington St SW, Blacksburg, VA 24060'
  };

  static List<String> locationNames = mappings.keys.toList();

  /// Will transform a U.S Postal formatted address into a [Location] instance.
  /// "<deliv_addr>, <city>, <State> <Zip>"
  static Location transformAddressIntoLocation(
      {required String address, String? label}) {
    List<String> elements = address.split(",");
    Location loc = Location(
        address: elements[0],
        city: elements[1].trim(),
        state: elements[2].split(" ")[1],
        zip: elements[2].split(" ")[2],
        label: label ?? elements[1].trim(),
        locationImageUrl: null);
    return loc;
  }
}
