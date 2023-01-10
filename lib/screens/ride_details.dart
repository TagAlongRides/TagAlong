import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/screens/stripe_payment/ride_stripe_payment_screen.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_departure_data.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_misc.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_pricing.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_profile_notes.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_location.dart';

class RideDetails extends StatelessWidget {
  const RideDetails({Key? key}) : super(key: key);
  static const routeName = '/ride_details';

  @override
  Widget build(BuildContext context) {
    var rideDetailsViewModel = Provider.of<RideDetailsViewModel>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Ride Details"),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            // SizedBox + Departure Date/Time
            const SizedBox(height: 16.0),
            RideDetailDepartureData(context: context, ride: rideDetailsViewModel.ride),

            // SizedBox + Locations
            const SizedBox(height: 16.0),
            RideDetailLocation(context: context, ride: rideDetailsViewModel.ride),

            // SizedBox + Profile & Notes
            const SizedBox(height: 16.0),
            RideDetailProfileNotes(context: context, ride: rideDetailsViewModel.ride),

            // Ride details (Car + Bags + optional COVID precautions)
            RideDetailMisc(context: context, ride: rideDetailsViewModel.ride),

            // SizedBox + Pricing
            const SizedBox(height: 16.0),
            RideDetailPricing(context: context, ride: rideDetailsViewModel.ride)
          ],
        )));
  }
}
