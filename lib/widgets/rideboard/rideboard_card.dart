import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/screens/ride_details.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// A ride on the Ride Board.
///
/// Time first, then the route on a panel tinted by direction (peach to
/// campus, sky from campus), then the driver and how many seats are left.
/// Tapping opens [RideDetails].
class RideBoardCard extends StatelessWidget {
  const RideBoardCard({required this.ride, Key? key}) : super(key: key);

  final RideModel ride;

  static String placeName(Location location) => (location.label ?? location.city).toTitleCase() as String;

  @override
  Widget build(BuildContext context) {
    final seatsLeft = ride.remainingSeats;
    final vehicle = [ride.vehicle.make, ride.vehicle.model].where((s) => s.isNotEmpty).join(' ');

    return Semantics(
      button: true,
      label: '${ride.toCampus ? 'To campus' : 'From campus'} ride at ${ride.departureTimeLabel}, '
          '${DateFormat('EEEE MMMM d').format(ride.departureDateTime)}, '
          'from ${placeName(ride.pickupLocation)} to ${placeName(ride.dropoffLocation)}, '
          '\$${ride.price}, $seatsLeft ${seatsLeft == 1 ? 'seat' : 'seats'} left',
      excludeSemantics: true,
      child: TagAlongCard(
        onTap: () {
          // Set up the RideDetailsViewModel with this card's ride.
          Provider.of<RideDetailsViewModel>(context, listen: false).instantiateRide(ride: ride);
          logger.log.fine('RideBoardCard - Tapped on Card');
          Navigator.pushNamed(context, RideDetails.routeName);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // When + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TagAlongTag.direction(ride.toCampus),
                      const SizedBox(height: TagAlongSpace.s2),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: TagAlongSpace.s2,
                        children: [
                          Text(ride.departureTimeLabel, style: TagAlongText.titleLarge),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              DateFormat('EEE, MMM d').format(ride.departureDateTime),
                              style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${ride.price}', style: TagAlongText.price),
                    Text('+ fees', style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Route
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: TagAlongSpace.s3),
              decoration: BoxDecoration(
                color: TagAlongColors.directionSoft(ride.toCampus),
                borderRadius: TagAlongRadius.mdAll,
              ),
              child: TagAlongRouteTimeline(
                pickup: RouteStop(title: placeName(ride.pickupLocation)),
                dropoff: RouteStop(title: placeName(ride.dropoffLocation)),
              ),
            ),
            const SizedBox(height: 14),

            // Driver + seats
            Row(
              children: [
                TagAlongAvatar(
                  name: ride.driverFullName,
                  imageUrl: ride.driverProfilePictureUrl,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.getFirstNameAndInitial(), style: TagAlongText.labelMedium),
                      if (vehicle.isNotEmpty)
                        Text(
                          vehicle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
                        ),
                    ],
                  ),
                ),
                TagAlongSeatDots(total: ride.noPassengers, taken: ride.noPassengers - seatsLeft),
                const SizedBox(width: TagAlongSpace.s2),
                seatsLeft == 1
                    ? const TagAlongTag(label: '1 seat left', tone: TagTone.butter)
                    : Text('$seatsLeft left', style: TagAlongText.labelMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
