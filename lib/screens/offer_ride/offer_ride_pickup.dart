import 'package:flutter/material.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_dropoff.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_location_step.dart';

/// Step 2 of Offer Ride: where passengers are picked up.
class OfferRidePickup extends StatelessWidget {
  const OfferRidePickup({Key? key}) : super(key: key);
  static const routeName = '/offer_ride_pickup';

  @override
  Widget build(BuildContext context) {
    return const OfferRideLocationStep(
      isPickup: true,
      step: 2,
      totalSteps: 6,
      nextRoute: OfferRideDropoff.routeName,
    );
  }
}
