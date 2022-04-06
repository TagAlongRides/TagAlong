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
            const SizedBox(height: 16.0),
            _getDepartureData(context, rideDetailsViewModel.ride),

            // SizedBox + Locations
            const SizedBox(height: 16.0),
            _getLocationData(context, rideDetailsViewModel.ride),

            // SizedBox + Profile & Notes
            const SizedBox(height: 16.0),
            _getProfileAndNotes(context, rideDetailsViewModel.ride),

            // Ride details (Car + Bags + optional COVID precautions)
            _getRideDetails(context, rideDetailsViewModel.ride),

            // SizedBox + Pricing
            const SizedBox(height: 16.0),
            _getPricing(context, rideDetailsViewModel.ride)

          ]
        )
      )
    );
  }
  
  Widget _getDepartureData(BuildContext context, Ride ride) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: IntrinsicHeight(
        child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text(
                      DateFormat('EEEE MMM d').format(ride.departureDateTime),
                      style: Theme.of(context).textTheme.headline2
                  )
              ),
              const Expanded(
                flex: 1,
                child:VerticalDivider(
                  thickness: 1,
                )
              ),
              Expanded(
                flex: 1,
                child: Text(
                    ride.departureTimeOfDay,
                    style: Theme.of(context).textTheme.headline2
                )
              )
            ]
        ),
      ),
    );
  }


  Widget _getLocationData(BuildContext context, Ride ride) {
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
                  ride.pickupLocation.label ?? ride.pickupLocation.city,
                  style: Theme.of(context).textTheme.headline2
                )
              ),
              Expanded(
                  child: Text(
                      ride.dropoffLocation.label ?? ride.dropoffLocation.city,
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
                  ride.pickupLocation.toString(),
                  style: Theme.of(context).textTheme.bodyText2,
                )
              ),
              Expanded(
                child: Text(
                  ride.dropoffLocation.toString(),
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

  Widget _getProfileAndNotes(BuildContext context, Ride ride) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
      child: Column(
        children: [
          // Profile picture and Deep-link Facebook Button
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

          // Ride Notes
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
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
            padding: EdgeInsets.all(16),
            child: Divider(
              thickness: 1
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
          // IF covid precautions were required, introduce INFO (i) button
          if (ride.vaccinationCard)
            const SizedBox(height: 16),
          if (ride.vaccinationCard)
            Row(
                children: [
                  const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.masks)
                  ),
                  const Text('COVID safety precautions required'),
                  const SizedBox(width: 16),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    constraints: const BoxConstraints(),
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
                                child: const Text('OK'),
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

  Widget _getPricing(BuildContext context, Ride ride) {
    var rideDetailsViewModel = Provider.of<RideDetailsViewModel>(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${ride.price}')
            ]
          ),
          const SizedBox(height: 16),

          // Service Fee
          Row(
            children: [
              const Text('Service Fee'),
              const SizedBox(width: 16),
              IconButton(
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.info_outline),
                  onPressed: () async {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              title: const Text('Pricing Details'),
                              content: const Text('This fee helps support TagAlong’s platform and covers a broad range of operating costs including app maintenance and support.'),
                              actions: <Widget>[
                                TextButton(
                                    child: const Text('OK'),
                                    onPressed: () => Navigator.pop(context)
                                )
                              ]
                          );
                        }
                    );
                  }
              ),
              const Spacer(),
              Text('\$${rideDetailsViewModel.getServiceFee()}'),
            ]
          ),
          // "Continue" Button
          const SizedBox(height: 16),
          ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Continue'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('\$${rideDetailsViewModel.getTotalPrice()}')
                  )
                ]
              ),
              onPressed: () {

              }
          )
        ]
      )
    );
  }

}
