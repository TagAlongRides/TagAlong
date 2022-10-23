import 'package:flutter/material.dart';
import 'package:ride_repo/ride_repo.dart';

extension on String {
  _toProperCase() {
    if (this == null) {
      return null;
    }
    if (length == 1) {
      return toUpperCase();
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  toTitleCase() {
    return replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str._toProperCase()).join(' ');
  }
}

class RideDetailLocation extends StatelessWidget {
  const RideDetailLocation({
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
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Expanded(child: Icon(Icons.trip_origin)),
            // TODO: Perhaps there's a better way to do the dashes..
            Text('  -----------------------------  '),
            Expanded(child: Icon(Icons.sports_score))
          ]),
          Row(children: [
            Expanded(
              child: Text(
                (ride.pickupLocation.label ?? ride.pickupLocation.city).toTitleCase() as String,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Expanded(
              child: Text(
                (ride.dropoffLocation.label ?? ride.dropoffLocation.city).toTitleCase() as String,
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.right,
              ),
            )
          ]),
          Row(children: [
            Expanded(
                child: Text(
              '${ride.pickupLocation.address} \n${ride.pickupLocation.city}, ${ride.pickupLocation.state} ${ride.pickupLocation.zip}',
              style: Theme.of(context).textTheme.bodyText2,
            )),
            Expanded(
                child: Text(
              '${ride.dropoffLocation.address} \n${ride.dropoffLocation.city}, ${ride.dropoffLocation.state} ${ride.dropoffLocation.zip}',
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.right,
            ))
          ])
        ]));
  }
}
