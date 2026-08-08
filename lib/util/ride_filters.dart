import 'package:ride_repo/ride_repo.dart';

/// The filters a passenger can apply to the Ride Board (Milestone 2, §11).
///
/// All filters are optional and combine with one another. The school filter is
/// deliberately absent — it is always the user's own school and is applied by
/// [RideBoardViewModel] rather than chosen here.
class RideFilters {
  const RideFilters({
    this.toCampus,
    this.departureDateStart,
    this.departureDateEnd,
    this.day = false,
    this.night = false,
    this.destination,
  });

  /// True for rides heading to campus, false for rides leaving campus, null
  /// for both.
  final bool? toCampus;

  /// Earliest departure to show. Null means "from now".
  final DateTime? departureDateStart;

  /// Latest departure to show. Null means no upper bound.
  final DateTime? departureDateEnd;

  /// Show rides departing between 6:00am and 5:59pm.
  final bool day;

  /// Show rides departing between 6:00pm and 5:59am.
  final bool night;

  /// "City, ST" of the non-campus end of the ride, or null for anywhere.
  final String? destination;

  /// Hour at which day begins.
  static const int dayStartHour = 6;

  /// Hour at which night begins.
  static const int nightStartHour = 18;

  /// The "City, ST" of the non-campus end of [ride].
  ///
  /// A ride to campus is picked up off campus; a ride from campus is dropped
  /// off off campus.
  static String cityStateOf(RideModel ride) {
    final location = ride.toCampus ? ride.pickupLocation : ride.dropoffLocation;
    if (location.city.isEmpty) {
      return '';
    }
    return '${location.city}, ${location.state}';
  }

  /// Whether [ride] survives the filters we can't push into Firestore.
  bool matches(RideModel ride) {
    // A fully booked ride comes off the board entirely (Milestone 2, §12.3).
    if (ride.remainingSeats <= 0) {
      return false;
    }
    if (!_matchesTimeOfDay(ride.departureDateTime)) {
      return false;
    }
    if (destination != null && RideFilters.cityStateOf(ride) != destination) {
      return false;
    }
    return true;
  }

  /// Day is 6:00am - 5:59pm, night is 6:00pm - 5:59am. Selecting both or
  /// neither shows every time of day.
  bool _matchesTimeOfDay(DateTime departure) {
    if (day == night) {
      return true;
    }
    final isDaytime = departure.hour >= dayStartHour && departure.hour < nightStartHour;
    return day ? isDaytime : !isDaytime;
  }

  RideFilters copyWith({
    bool? toCampus,
    DateTime? departureDateStart,
    DateTime? departureDateEnd,
    bool? day,
    bool? night,
    String? destination,
    bool clearToCampus = false,
    bool clearDates = false,
    bool clearDestination = false,
  }) {
    return RideFilters(
      toCampus: clearToCampus ? null : (toCampus ?? this.toCampus),
      departureDateStart: clearDates ? null : (departureDateStart ?? this.departureDateStart),
      departureDateEnd: clearDates ? null : (departureDateEnd ?? this.departureDateEnd),
      day: day ?? this.day,
      night: night ?? this.night,
      destination: clearDestination ? null : (destination ?? this.destination),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RideFilters &&
        other.toCampus == toCampus &&
        other.departureDateStart == departureDateStart &&
        other.departureDateEnd == departureDateEnd &&
        other.day == day &&
        other.night == night &&
        other.destination == destination;
  }

  @override
  int get hashCode =>
      Object.hash(toCampus, departureDateStart, departureDateEnd, day, night, destination);

  @override
  String toString() =>
      'RideFilters(toCampus: $toCampus, start: $departureDateStart, end: $departureDateEnd, '
      'day: $day, night: $night, destination: $destination)';
}
