import 'package:flutter/foundation.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/util/pricing.dart';

/// The Viewmodel for the "Ride Details" Page
class RideDetailsViewModel with ChangeNotifier {
  late RideModel ride;

  /// Whether the price breakdown section is expanded. Collapsed by default
  /// per Milestone 3, §2.1.3.
  bool _priceExpanded = false;

  bool get priceExpanded => _priceExpanded;

  /// Will instantiate this ViewModel's [RideModel] instance.
  /// This MUST be called before user fully navigates to the [RideDetails]
  void instantiateRide({required RideModel ride}) {
    this.ride = ride;
    _priceExpanded = false;
  }

  /// Expands or collapses the total price breakdown.
  void togglePriceExpanded() {
    _priceExpanded = !_priceExpanded;
    notifyListeners();
  }

  /// The driver's price per passenger, formatted.
  String getSubtotal() => Pricing.format(Pricing.subtotal(ride.price));

  /// The service fee on this ride, formatted.
  String getServiceFee() => Pricing.format(Pricing.serviceFee(ride.price));

  /// The taxes on this ride, formatted.
  String getTax() => Pricing.format(Pricing.tax(ride.price));

  /// What the passenger pays in total, formatted.
  String getTotalPrice() => Pricing.format(Pricing.total(ride.price));

  /// "x of y Seats Left" (Milestone 3, §2.1.1).
  String getSeatsLeftMessage() => '${ride.remainingSeats} of ${ride.noPassengers} Seats Left';
}
