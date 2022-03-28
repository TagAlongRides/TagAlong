import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/ride_details_view_model.dart';

class RideDetails extends StatelessWidget {
  const RideDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rideDetailsViewModel = Provider.of<RideDetailsViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SizedBox + Departure Date/Time
            SizedBox(height: 12.0),
            _getDepartureData(context, rideDetailsViewModel),

            // SizedBox +
            SizedBox(height: 12.0),
            _getLocationData(context, rideDetailsViewModel)
          ]

        )
      )
    );
  }
  
  Widget _getDepartureData(BuildContext context, RideDetailsViewModel rideDetailsViewModel) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Text(
                    DateFormat('EEEE MMM d').format(rideDetailsViewModel.ride.departureDateTime),
                    style: Theme.of(context).textTheme.headline2
                )
            ),
            // TODO: Fix! Not appearing...
            const VerticalDivider(
                width: 20,
                thickness: 10,
                indent: 20,
                endIndent: 0,
                color: Colors.green),
            Expanded(
                flex: 1,
                child: Text(
                    '${rideDetailsViewModel.ride.departureTimeOfDay}',
                    style: Theme.of(context).textTheme.headline2
                )
            )
          ]
      ),
    );
  }


  Widget _getLocationData(BuildContext context, RideDetailsViewModel rideDetailsViewModel) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Icon(Icons.trip_origin)),
              Text('  -----------------------------  '),
              Expanded(child: Icon(Icons.sports_score))
            ]
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "${rideDetailsViewModel.ride.pickupLocation.label ?? rideDetailsViewModel.ride.pickupLocation.city}",
                  style: Theme.of(context).textTheme.headline2
                )
              ),
              Expanded(
                  child: Text(
                      "${rideDetailsViewModel.ride.dropoffLocation.label ?? rideDetailsViewModel.ride.dropoffLocation.city}",
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.right,
                  )
              )
            ]
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  rideDetailsViewModel.ride.pickupLocation.address
                )
              )
            ]
          )
        ]
      )
    );
  }

}
