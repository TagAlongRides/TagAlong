import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/services/places_service.dart';
import 'package:tagalong/widgets/offer_ride/location_search_field.dart';

Map<String, dynamic> _placeJson({String? name, List<String>? types}) => {
      'place_id': 'p1',
      'name': name,
      'address': '1 Saarinen Cir',
      'city': 'Dulles',
      'state': 'VA',
      'zip': '20166',
      'formatted_address': '1 Saarinen Cir, Dulles, VA 20166, USA',
      'latitude': 38.95,
      'longitude': -77.45,
      'precise': true,
    };

class _FakePlaces extends PlacesService {
  _FakePlaces({this.geocodeResult});

  final GeocodeResult? geocodeResult;
  final searched = <String>[];

  @override
  Future<List<PlaceSuggestion>> autocomplete(String input, {required String sessionToken}) async {
    searched.add(input);
    return const [
      PlaceSuggestion(placeId: 'p1', mainText: 'Dulles International Airport', secondaryText: 'Dulles, VA'),
    ];
  }

  @override
  Future<ResolvedPlace> details(String placeId, {required String sessionToken}) async =>
      ResolvedPlace.fromJson(_placeJson(name: 'Dulles International Airport'));

  @override
  Future<GeocodeResult> geocode(String address) async => geocodeResult!;
}

void main() {
  group('ResolvedPlace.fromJson', () {
    test('a named place goes in the address line and leaves the label empty', () {
      final place = ResolvedPlace.fromJson(_placeJson(name: 'Dulles International Airport'));
      expect(place.title, 'Dulles International Airport');
      expect(place.location.address, 'Dulles International Airport, 1 Saarinen Cir');
      expect(place.location.label, isNull, reason: 'cards show the off-campus end by city');
      expect(place.formattedAddress, '1 Saarinen Cir, Dulles, VA 20166');
    });

    test('a plain address keeps its street and coordinates', () {
      final place = ResolvedPlace.fromJson(_placeJson());
      expect(place.title, '1 Saarinen Cir');
      expect(place.location.address, '1 Saarinen Cir');
      expect(place.location.latitude, 38.95);
      expect(place.location.placeId, 'p1');
    });
  });

  test('Location round-trips its place id and coordinates, and reads old rides without them', () {
    final json = ResolvedPlace.fromJson(_placeJson()).location.toJson();
    final back = Location.fromJson(json);
    expect(back.placeId, 'p1');
    expect(back.longitude, -77.45);

    final old = Location.fromJson({'address': 'a', 'city': 'b', 'zip': 'c', 'state': 'VA'});
    expect(old.placeId, isNull);
    expect(old.toJson().containsKey('latitude'), isFalse);
  });

  group('LocationSearchField', () {
    Future<GlobalKey<LocationSearchFieldState>> pump(
      WidgetTester tester,
      PlacesService places,
      List<ResolvedPlace?> changes,
    ) async {
      final key = GlobalKey<LocationSearchFieldState>();
      ResolvedPlace? value;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => LocationSearchField(
              key: key,
              value: value,
              accent: Colors.orange,
              placesService: places,
              onChanged: (p) {
                changes.add(p);
                setState(() => value = p);
              },
            ),
          ),
        ),
      ));
      return key;
    }

    testWidgets('typing shows suggestions and picking one resolves it', (tester) async {
      final places = _FakePlaces();
      final changes = <ResolvedPlace?>[];
      await pump(tester, places, changes);

      await tester.enterText(find.byType(TextField), 'dulles');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      expect(places.searched, ['dulles']);
      expect(find.text('Google Maps'), findsOneWidget);

      await tester.tap(find.text('Dulles International Airport'));
      await tester.pumpAndSettle();
      expect(changes.single!.location.zip, '20166');
      expect(find.text('Change'), findsOneWidget);
    });

    testWidgets('a typed address Google matches exactly is accepted', (tester) async {
      final places = _FakePlaces(
          geocodeResult: GeocodeResult(status: GeocodeStatus.found, place: ResolvedPlace.fromJson(_placeJson())));
      final changes = <ResolvedPlace?>[];
      final key = await pump(tester, places, changes);

      await tester.enterText(find.byType(TextField), '1 Saarinen Circle');
      expect(await key.currentState!.resolve(), isTrue);
      await tester.pumpAndSettle();
      expect(changes.single!.formattedAddress, '1 Saarinen Cir, Dulles, VA 20166');
    });

    testWidgets('a partial match is filled in but needs confirming', (tester) async {
      final places = _FakePlaces(
          geocodeResult:
              GeocodeResult(status: GeocodeStatus.found, partial: true, place: ResolvedPlace.fromJson(_placeJson())));
      final changes = <ResolvedPlace?>[];
      final key = await pump(tester, places, changes);

      await tester.enterText(find.byType(TextField), '1 Sarinen');
      expect(await key.currentState!.resolve(), isFalse);
      await tester.pumpAndSettle();
      expect(find.textContaining('Is this the right place?'), findsOneWidget);
      // The second tap goes through.
      expect(await key.currentState!.resolve(), isTrue);
    });

    testWidgets('an address Google can\'t find is refused with a reason', (tester) async {
      final places = _FakePlaces(geocodeResult: const GeocodeResult(status: GeocodeStatus.notFound));
      final changes = <ResolvedPlace?>[];
      final key = await pump(tester, places, changes);

      await tester.enterText(find.byType(TextField), 'zzzz qqqq');
      expect(await key.currentState!.resolve(), isFalse);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(find.textContaining('couldn’t find that address'), findsOneWidget);
    });

    testWidgets('a whole city is refused as too vague', (tester) async {
      final vague = ResolvedPlace.fromJson({..._placeJson(), 'formatted_address': 'Dulles, VA, USA', 'precise': false});
      final places = _FakePlaces(geocodeResult: GeocodeResult(status: GeocodeStatus.tooVague, place: vague));
      final changes = <ResolvedPlace?>[];
      final key = await pump(tester, places, changes);

      await tester.enterText(find.byType(TextField), 'Dulles VA');
      expect(await key.currentState!.resolve(), isFalse);
      await tester.pumpAndSettle();
      expect(find.textContaining('is a whole area'), findsOneWidget);
    });

    testWidgets('continuing with nothing typed asks for an address', (tester) async {
      final key = await pump(tester, _FakePlaces(), []);
      expect(await key.currentState!.resolve(), isFalse);
      await tester.pump();
      expect(find.text('Search for an address or place'), findsOneWidget);
    });
  });
}
