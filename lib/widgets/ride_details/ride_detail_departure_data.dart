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
      child: IntrinsicHeight(
        child: Row(children: [
          Expanded(
              flex: 2,
              child: Text(DateFormat('EEEE MMM d').format(ride.departureDateTime),
                  style: Theme.of(context).textTheme.headline6)),
          const Expanded(
              flex: 1,
              child: VerticalDivider(
                thickness: 1,
              )),
          Expanded(flex: 1, child: Text(ride.departureTimeOfDay, style: Theme.of(context).textTheme.headline6))
        ]),
      ),
    );
  }
}
