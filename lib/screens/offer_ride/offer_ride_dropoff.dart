import 'package:flutter/material.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_departure.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_location_step.dart';

/// Step 3 of Offer Ride: where passengers are dropped off.
class OfferRideDropoff extends StatelessWidget {
  const OfferRideDropoff({Key? key}) : super(key: key);
  static const routeName = '/offer_ride_dropoff';

  @override
  Widget build(BuildContext context) {
    return const OfferRideLocationStep(
      isPickup: false,
      step: 3,
      totalSteps: 6,
      nextRoute: OfferRideDeparture.routeName,
    );
  }
}
