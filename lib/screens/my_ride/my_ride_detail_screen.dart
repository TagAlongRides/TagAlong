import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_departure_data.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_location.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_misc.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_pricing.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_profile_notes.dart';

class MyRideDetailScreen extends StatelessWidget {
  const MyRideDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/my-ride-detail';

  @override
  Widget build(BuildContext context) {
    final _userId = Provider.of<TagAlongUserViewModel>(context, listen: false).tagAlongUser!.id;
    final _rideData = ModalRoute.of(context)!.settings.arguments as RideModel;
    final _isFutureRide = _rideData.departureDateTime.isAfter(DateTime.now());
    final _userIsDriver = _rideData.driverId == _userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isFutureRide ? 'My Upcoming Ride' : 'My Past Ride'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SizedBox + Departure Date/Time
            const SizedBox(height: 16.0),
            RideDetailDepartureData(
              context: context,
              ride: _rideData,
            ),

            // SizedBox + Locations
            const SizedBox(height: 16.0),
            RideDetailLocation(
              context: context,
              ride: _rideData,
            ),

            // SizedBox + Profile & Notes
            const SizedBox(height: 16.0),
            RideDetailProfileNotes(
              context: context,
              ride: _rideData,
              isDriver: _userIsDriver,
              isInFuture: _isFutureRide,
              isMyRides: true,
            ),

            if (!_userIsDriver)
              // Ride details (Car + Bags + optional COVID precautions)
              RideDetailMisc(
                context: context,
                ride: _rideData,
              ),

            // SizedBox + Pricing
            const SizedBox(height: 16.0),
            RideDetailPricing(
              context: context,
              ride: _rideData,
              isDriver: _userIsDriver,
            )
          ],
        ),
      ),

      // return Container(
      //   margin: const EdgeInsets.all(4),
      //   padding: const EdgeInsets.all(12),
      //   decoration: BoxDecoration(
      //     color: Colors.grey.withOpacity(.3),
      //     borderRadius: const BorderRadius.all(
      //       Radius.circular(8),
      //     ),
      //   ),
      //   child: Column(
      //     children: [
      //       Text(rideData.rideId),
      //       LoadingButton(
      //           onPressed: () async {
      //             final ride = await RideRepository.instance.getRideById(rideData.rideId);
      //             if (ride.departureDateTime.difference(DateTime.now()).inHours > 6) {
      //               InfoDialog.show(
      //                 context,
      //                 message: 'Are you sure you want to cancel the ride ? Refund = true',
      //                 positiveLabel: 'Continue',
      //                 // positivePress: () async {
      //                 //   // 1. Init the refund from the stripe side
      //                 //   final refund = await StripeRefundRepository.instance.refundDestinationCharge(
      //                 //     StripeRefundRequest(
      //                 //       charge: rideBooking.chargeId,
      //                 //       reverseTransfer: true,
      //                 //       refundApplicationFee: true,
      //                 //     ),
      //                 //   );

      //                 //   // 2. Update the firebase collection to cancel the ride booking
      //                 //   final ridebookingUpdated =
      //                 //       await RideBookingRepository.instance.cancelRideBooking(rideBooking);

      //                 //   // 3. Increment remainingSeats by 1 and update in Firebase
      //                 //   ride.remainingSeats++;
      //                 //   await RideRepository.instance.updateRide(ride);

      //                 //   setState(() {});

      //                 //   Navigator.of(context).pop();
      //                 // },
      //               );
      //             } else {
      //               // TODO - Prevent user from being able to cancel within 6 hours
      //               InfoDialog.show(
      //                 context,
      //                 message: 'Are you sure you want to cancel the ride ? Refund = false',
      //                 positiveLabel: 'Continue',
      //                 // positivePress: () async {
      //                 //   /// 1. Update the firebase collection to cancel the ride booking
      //                 //   final ridebookingUpdated =
      //                 //       await RideBookingRepository.instance.cancelRideBooking(rideBooking);

      //                 //   setState(() {});

      //                 //   Navigator.of(context).pop();
      //                 // },
      //               );
      //             }
      //             // final message =
      //           },
      //           text: 'Cancel')
      //     ],
      //   ),
      // );
    );
  }
}
