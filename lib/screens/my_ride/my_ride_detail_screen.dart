import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_cancelled_message.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_hero.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_pricing.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_profile_notes.dart';

/// A ride the user is driving or has booked, from My Rides.
class MyRideDetailScreen extends StatelessWidget {
  const MyRideDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/my-ride-detail';

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<TagAlongUserViewModel>(context, listen: false).tagAlongUser!.id;
    final ride = ModalRoute.of(context)!.settings.arguments as RideModel;
    final isFutureRide = ride.departureDateTime.isAfter(DateTime.now());
    final userIsDriver = ride.driverId == userId;

    // Flag if the entire ride is cancelled or the passenger's booking is cancelled.
    // Identifying a cancelled booking by checking against the list of current riderIds for the ride
    final isCancelled = ride.status == RideStatus.canceled || (!userIsDriver && !ride.riderIds.contains(userId));

    const gap = SizedBox(height: TagAlongSpace.s4);

    return Scaffold(
      appBar: TagAlongTopBar(title: isFutureRide ? 'Upcoming ride' : 'Past ride'),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s2, TagAlongSpace.gutter, TagAlongSpace.s10),
        children: [
          if (isCancelled) ...[const RideDetailCancelledMessage(), gap],
          RideDetailHero(ride: ride, showSeats: userIsDriver && isFutureRide && !isCancelled),
          if (!isCancelled) ...[
            gap,
            RideDetailProfileNotes(
              context: context,
              ride: ride,
              isDriver: userIsDriver,
              isInFuture: isFutureRide,
              isMyRides: true,
              isCancelled: isCancelled,
              // Car + bags + optional COVID precautions
              showFacts: !userIsDriver && isFutureRide,
            ),
            gap,
            RideDetailPricing(
              context: context,
              ride: ride,
              userId: userId,
              isDriver: userIsDriver,
              isInFuture: isFutureRide,
              isMyRides: true,
              isCancelled: isCancelled,
            ),
          ],
        ],
      ),
    );
  }
}
