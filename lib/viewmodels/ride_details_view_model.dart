import 'package:flutter/foundation.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:intl/intl.dart';

/// The Viewmodel for the "Ride Details" Page
class RideDetailsViewModel with ChangeNotifier {

  late Ride ride;


  /// Will instantiate this ViewModel's [Ride] instance.
  /// This MUST be called before user fully navigates to the [RideDetails]
  void instantiateRide({required Ride ride}) {
    this.ride = ride;
  }

  /// Returns the service fee on a given ride based on the following algorithm.
  /// serviceFee = ride.price * .20
  String getServiceFee() {
    var formatter = NumberFormat('##.##', 'en_US');
    return formatter.format(ride.price * .20);
  }

  /// Returns the total ride price based on the following algorithm:
  /// totalPrice = ride.price + getServiceFee()
  String getTotalPrice() {
    var formatter = NumberFormat('##.##', 'en_US');
    return formatter.format(ride.price + ride.price * .20);
  }
}