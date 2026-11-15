import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ride_repo/ride_repo.dart';

class RideDetailDepartureData extends StatelessWidget {
  const RideDetailDepartureData({
    Key? key,
    required this.context,
    required this.ride,
  }) : super(key: key);

  final BuildContext context;
  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Text(DateFormat('EEEE MMM d').format(ride.departureDateTime),
                      style: Theme.of(context).textTheme.titleLarge)),
              const Expanded(
                  flex: 1,
                  child: VerticalDivider(
                    thickness: 1,
                  )),
              Expanded(flex: 1, child: Text(ride.departureTimeOfDay, style: Theme.of(context).textTheme.titleLarge))
            ]),
          ),
          const SizedBox(height: 8),
          // "x of y Seats Left" (Milestone 3, §2.1.1)
          Text(
            '${ride.remainingSeats} of ${ride.noPassengers} Seats Left',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
