import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/ride_details_view_model.dart';


/// Represents a RideBoardCard, the only element that should be shown on the
/// RideBoard, and should surface basic information about a Ride as well as
/// lead to a more detailed page onTap.
class RideBoardCard extends StatelessWidget {
  const RideBoardCard({required this.ride, Key? key}) : super(key: key);

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var rideDetailsViewModel = Provider.of<RideDetailsViewModel>(context, listen: false);
        // Set up the RideDetailsViewModel with this card's [Ride] instance
        rideDetailsViewModel.instantiateRide(ride: ride);
        logger.log.fine("RideBoardCard - Tapped on Card");
        Navigator.pushNamed(context, '/ride_details');
      },
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(
            color: Color.fromRGBO(145, 127, 159, .6)
          )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12
          ),
          child: SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      _getLocations(ride),      // To-From Locations (Expanded)
                      _getDriverData(ride)      // Driver Name, Picture (Expanded)
                    ]
                  )
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _getPrice(ride),          // Price of Ride (Expanded)
                      _getDepartureDate(ride),  // Departure Date (Row)
                      _getDepartureTime(ride),  // Departure Time (Row)
                      _getRemainingSeats(ride)  // Remaining Seats (Expanded)
                    ],
                  ),
                )
              ]
            )
          )
        )
      ),
    );
  }


  /// Returns an Expanded Column widget which details the "To-From" Locations
  /// of a given [Ride]. This Widget MUST be used within a Row/Column.
  /// The [Ride] fields this utilizes is:
  /// 1. Pickup Location
  /// 2. Dropoff Location
  Widget _getLocations(Ride ride) {
    // Column parent
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.circle_outlined,
                size: 24,
              ),
              const SizedBox(width: 6),
              // PICKUP / ORIGIN
              Expanded(
                child: Text(
                  ride.pickupLocation.label ?? ride.pickupLocation.city,
                  style: TagAlongTheme.lightTextTheme.headline6,
                ),
              ),
            ]
          ),
          const Icon(
            Icons.more_vert,
            size: 24,
          ),
          Row(
            children: [
              const Icon(
                Icons.circle_rounded,
                size: 24,
              ),
              const SizedBox(width: 6),
              // DROPOFF / DESTINATION
              Expanded(
                child: Text(
                  ride.dropoffLocation.label ?? ride.dropoffLocation.city,
                  style: TagAlongTheme.lightTextTheme.headline6,
                )
              ),
            ],
          ),
        ]
      )

    );
  }


  /// Returns an Expanded Widget that exposes the Driver's
  /// 1. First Name, last initial
  /// 2. Facebook Profile Picture
  /// This widget MUST be used within a Column/Row.
  Widget _getDriverData(Ride ride) {
    var firstNameWithInitial = ride.getFirstNameAndInitial();
    return Expanded(
      flex: 1,
      //alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(ride.driverProfilePictureUrl),
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            firstNameWithInitial,
            style: TagAlongTheme.lightTextTheme.headline6,
          ),
        ],
      ),
    );
  }

  Widget _getPrice(Ride ride) {
    return Expanded(
      child: Container(
        child: Text(
          "\$${ride.price}",
          style: TagAlongTheme.lightTextTheme.headline1,
          // textAlign: TextAlign.right,
        ),
        alignment: Alignment.topRight,
      ),
    );
  }


  Widget _getDepartureDate(Ride ride) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          DateFormat('EEEE MMM d').format(ride.departureDateTime),
          style: TagAlongTheme.lightTextTheme.bodyText1,
        ),
        const SizedBox(
          width: 3,
        ),
        const Icon(
          Icons.today_outlined,
          size: 16,
        ),
      ],
    );
  }


  Widget _getDepartureTime(Ride ride) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          // TODO: departureTime,
          ride.departureTimeOfDay,
          style: TagAlongTheme.lightTextTheme.bodyText1,
        ),
        const SizedBox(
          width: 3,
        ),
        const Icon(
          Icons.schedule_outlined,
          size: 16,
        )
      ],
    );
  }

  Widget _getRemainingSeats(Ride ride) {
    var seatsRemaining = ride.noPassengers - ride.riderIds.length;
    if (seatsRemaining > 1) {
      return Expanded(
        child: Container(
          alignment: Alignment.bottomRight,
          child:
            Text(
              "$seatsRemaining SEATS REMAINING",
              style: TagAlongTheme.lightTextTheme.overline,
          ),
        ),
      );
    }
    else {
      return Expanded(
        child: Container(
          alignment: Alignment.bottomRight,
          child:
          Text(
            "$seatsRemaining SEAT REMAINING",
            style: TagAlongTheme.lightTextTheme.overline,
          ),
        ),
      );
    }
  }
}
