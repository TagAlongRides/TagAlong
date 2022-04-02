import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RideDetails extends StatelessWidget {
  const RideDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rideDetailsViewModel = Provider.of<RideDetailsViewModel>(context, listen: false);
    double width = MediaQuery.of(context).size.width - 24.0;
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
            SizedBox(height: 16.0),
            _getDepartureData(context, rideDetailsViewModel),

            // SizedBox + Locations
            SizedBox(height: 16.0),
            _getLocationData(context, rideDetailsViewModel),

            // SizedBox + Profile & Notes
            SizedBox(height: 16.0),
            _getProfileAndNotes(context, rideDetailsViewModel.ride, width),

            _getRideDetails(context, rideDetailsViewModel.ride)
          ]

        )
      )
    );
  }
  
  Widget _getDepartureData(BuildContext context, RideDetailsViewModel rideDetailsViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text(
                      DateFormat('EEEE MMM d').format(rideDetailsViewModel.ride.departureDateTime),
                      style: Theme.of(context).textTheme.headline2
                  )
              ),
              const Expanded(
                flex: 1,
                child:VerticalDivider(
                  thickness: 1.75,
                )
              ),
              Expanded(
                flex: 1,
                child: Text(
                    rideDetailsViewModel.ride.departureTimeOfDay,
                    style: Theme.of(context).textTheme.headline2
                )
              )
            ]
        ),
      ),
    );
  }


  Widget _getLocationData(BuildContext context, RideDetailsViewModel rideDetailsViewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Expanded(child: Icon(Icons.trip_origin)),
              // TODO: Perhaps there's a better way to do the dashes..
              Text('  -----------------------------  '),
              Expanded(child: Icon(Icons.sports_score))
            ]
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  rideDetailsViewModel.ride.pickupLocation.label ?? rideDetailsViewModel.ride.pickupLocation.city,
                  style: Theme.of(context).textTheme.headline2
                )
              ),
              Expanded(
                  child: Text(
                      rideDetailsViewModel.ride.dropoffLocation.label ?? rideDetailsViewModel.ride.dropoffLocation.city,
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
                  rideDetailsViewModel.ride.pickupLocation.toString(),
                  style: Theme.of(context).textTheme.bodyText2,
                )
              ),
              Expanded(
                child: Text(
                  rideDetailsViewModel.ride.dropoffLocation.toString(),
                  style: Theme.of(context).textTheme.bodyText2,
                  textAlign: TextAlign.right,
                )
              )
            ]
          )
        ]
      )
    );
  }

  Widget _getProfileAndNotes(BuildContext context, Ride ride, double width) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          // Profile picture and Deep link Facebook Button
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(ride.driverProfilePictureUrl),
                      ),
                    ),
                    Text(
                        ride.getFirstNameAndInitial(),
                        style: Theme.of(context).textTheme.headline2
                    ),
                  ]
                )
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Respond to button press
                },
                icon: const FaIcon(FontAwesomeIcons.facebook),
                label: const Text("View Profile"),
              )
            ]
          ),

          // Ride/Driver Notes
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            child: Text(ride.notes),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12)
            )
          ),

          // Horizontal Divider
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Divider(
              thickness: 1.75
            ),
          )
        ]
      )
    );
  }

  Widget _getRideDetails(BuildContext context, Ride ride) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.directions_car_outlined)
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ride.vehicle.toString()),
                  Text(ride.vehicle.color)
                ]
              ),
            ]
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.backpack_outlined)
              ),
              Text('${ride.noBags} bags per person'),
            ]
          ),
          const SizedBox(height: 16),
          if (ride.vaccinationCard)
            Row(
                children: [
                  Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.masks)
                  ),
                  Flexible(child: Text('COVID safety precautions required')),
                  IconButton(
                    padding: EdgeInsets.only(left:16),
                    constraints: BoxConstraints(),
                    icon: const Icon(Icons.info_outline),
                    onPressed: () async {
                      return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('COVID Protocols Enforced'),
                            content: const Text('This Driver has indicated proof of vaccination or wearing a mask is required. Please ensure you bring your vaccination card and a mask to wear. Failure to do so, Drivers reserve the right to refuse providing a ride.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () => Navigator.pop(context)
                              )
                            ]
                          );
                        }
                      );
                    }
                  )
                ]
            )
        ]
      )
    );
  }

}
