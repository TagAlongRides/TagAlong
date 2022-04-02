import 'package:flutter/foundation.dart';
import 'package:tagalong/data/models/ride.dart';

/// The Viewmodel for the "Ride Details" Page
class RideDetailsViewModel with ChangeNotifier {

  late Ride ride;


  /// Will instantiate this ViewModel's [Ride] instance.
  /// This MUST be called before user fully navigates to the [RideDetails]
  void instantiateRide({required Ride ride}) {
    this.ride = ride;
  }
}