import 'package:core/core.dart';
import 'package:ride_repo/ride_repo.dart';

/// One row in the address suggestions list.
class PlaceSuggestion {
  const PlaceSuggestion({required this.placeId, required this.mainText, required this.secondaryText});

  final String placeId;

  /// "Dulles International Airport" or "123 Main St".
  final String mainText;

  /// "Dulles, VA, USA".
  final String secondaryText;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) => PlaceSuggestion(
        placeId: json['place_id'] as String,
        mainText: (json['main_text'] as String?) ?? '',
        secondaryText: (json['secondary_text'] as String?) ?? '',
      );
}

/// An address Google Maps was able to find.
class ResolvedPlace {
  const ResolvedPlace({
    required this.location,
    required this.formattedAddress,
    required this.precise,
    this.name,
  });

  /// What gets stored on the ride.
  final Location location;

  /// One line for display: "1600 Amphitheatre Pkwy, Mountain View, CA 94043".
  final String formattedAddress;

  /// False for a city, zip code or bare street: real, but not a spot to meet.
  final bool precise;

  /// The place's name ("Dulles International Airport"), when it has one apart
  /// from its street address.
  final String? name;

  /// The bold line on the selected-place card.
  String get title => name ?? location.address;

  factory ResolvedPlace.fromJson(Map<String, dynamic> json) {
    final formatted = (json['formatted_address'] as String?)?.replaceFirst(RegExp(r', USA$'), '');
    final name = json['name'] as String?;
    final street = (json['address'] as String?) ?? '';
    final location = Location(
      // The name rides along in the address line so the driver's meeting spot
      // is clear on Ride Details, while [label] stays empty: cards show an
      // off-campus end by its city.
      address: name == null || street.isEmpty ? (name ?? street) : '$name, $street',
      city: (json['city'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      zip: (json['zip'] as String?) ?? '',
      locationImageUrl: null,
      placeId: json['place_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
    return ResolvedPlace(
      location: location,
      name: name,
      formattedAddress: formatted ?? '$street, ${location.city}, ${location.state} ${location.zip}',
      precise: json['precise'] == true,
    );
  }
}

/// What checking a typed address against Google Maps found.
enum GeocodeStatus { found, tooVague, notFound }

class GeocodeResult {
  const GeocodeResult({required this.status, this.place, this.partial = false});

  final GeocodeStatus status;
  final ResolvedPlace? place;

  /// Google had to guess; ask the driver to confirm.
  final bool partial;

  factory GeocodeResult.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']) {
      'found' => GeocodeStatus.found,
      'too_vague' => GeocodeStatus.tooVague,
      _ => GeocodeStatus.notFound,
    };
    final location = json['location'];
    return GeocodeResult(
      status: status,
      place: location is Map<String, dynamic> ? ResolvedPlace.fromJson(location) : null,
      partial: json['partial'] == true,
    );
  }
}

/// Address autocomplete and validation, through the TagAlong API's
/// `/v1/places` routes. The Google key stays on the server.
class PlacesService {
  PlacesService({HttpApiClient? client}) : _client = client ?? HttpApiClient.instance;

  final HttpApiClient _client;

  Future<List<PlaceSuggestion>> autocomplete(String input, {required String sessionToken}) async {
    final body = await _client.get('places/autocomplete', data: {'input': input, 'sessionToken': sessionToken});
    final data = (body as Map<String, dynamic>)['data'] as List<dynamic>? ?? const [];
    return data.map((e) => PlaceSuggestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ResolvedPlace> details(String placeId, {required String sessionToken}) async {
    final body = await _client.get('places/details/${Uri.encodeComponent(placeId)}',
        data: {'sessionToken': sessionToken});
    return ResolvedPlace.fromJson((body as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<GeocodeResult> geocode(String address) async {
    final body = await _client.get('places/geocode', data: {'address': address});
    return GeocodeResult.fromJson((body as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
