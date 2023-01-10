import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_cancelled_message.dart';
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

    // Flag if the entire ride is cancelled or the passenger's booking is cancelled.
    // Identifying a cancelled booking by checking against the list of current riderIds for the ride
    final _isCancelled =
        _rideData.status == RideStatus.canceled || (!_userIsDriver && !_rideData.riderIds.contains(_userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isFutureRide ? 'My Upcoming Ride' : 'My Past Ride'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isCancelled) const SizedBox(height: 16.0),
            if (_isCancelled) const RideDetailCancelledMessage(),
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
            if (!_isCancelled) const SizedBox(height: 16.0),
            if (!_isCancelled)
              RideDetailProfileNotes(
                context: context,
                ride: _rideData,
                isDriver: _userIsDriver,
                isInFuture: _isFutureRide,
                isMyRides: true,
                isCancelled: _isCancelled,
              ),

            if (!_userIsDriver && _isFutureRide && !_isCancelled)
              // Ride details (Car + Bags + optional COVID precautions)
              RideDetailMisc(
                context: context,
                ride: _rideData,
              ),

            // SizedBox + Pricing
            const SizedBox(height: 16.0),
            if (!_isCancelled)
              RideDetailPricing(
                context: context,
                ride: _rideData,
                userId: _userId,
                isDriver: _userIsDriver,
                isInFuture: _isFutureRide,
                isMyRides: true,
                isCancelled: _isCancelled,
              )
          ],
        ),
      ),
    );
  }
}
