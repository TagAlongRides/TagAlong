import 'package:flutter/material.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:tagalong/themes/tagalong_theme.dart';

class RideBoardCard extends StatelessWidget {
  const RideBoardCard({required this.ride, Key? key}) : super(key: key);

  final Ride ride;

  @override
  Widget build(BuildContext context) {

    return Card(
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
        child: Container(
          height: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _getLocations(ride),
                    // Flexible(
                    //   fit: FlexFit.tight,
                    //   child: Container(
                    //     alignment: Alignment.centerLeft,
                    //     child: Row(
                    //       children: [
                    //         const Icon(
                    //           Icons.circle_outlined,
                    //           size: 16,
                    //         ),
                    //         SizedBox(width: 5),
                    //         Text(
                    //           // TODO: pickup / origin
                    //           ride.pickupLocation.city,
                    //           style: TagAlongTheme.lightTextTheme.headline6,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Container(
                    //   alignment: Alignment.centerLeft,
                    //   child: const Icon(
                    //     Icons.more_vert,
                    //     size: 24,
                    //   ),
                    // ),
                    // Flexible(
                    //   fit: FlexFit.tight,
                    //   child: Container(
                    //     alignment: Alignment.centerLeft,
                    //     child: Row(
                    //       children: [
                    //         const Icon(
                    //           Icons.circle_rounded,
                    //           size: 16,
                    //         ),
                    //         SizedBox(width: 5),
                    //         Text(
                    //           // TODO: destination,
                    //           ride.dropoffLocation.city,
                    //           style: TagAlongTheme.lightTextTheme.headline6,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      flex: 1,
                      //alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Text(
                              // TODO: driverName[0].toUpperCase(),
                              "S"
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            // TODO: driverName,
                            "Steven P",
                            style: TagAlongTheme.lightTextTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                  ]
                )
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                        child: Text(
                          // TODO: NumberFormat('\$##').format(price),
                          "\$30",
                          style: TagAlongTheme.lightTextTheme.headline1,
                          // textAlign: TextAlign.right,
                        ),
                        alignment: Alignment.topRight,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          // TODO: DateFormat('EEEE MMM d').format(departureDate),
                          ride.departureDateTime.toString(),
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
                    ),
                    Container(
                      child: Row(
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
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "1 SEAT REMAINING",
                          // seatsRemaining == 1
                          //     ? seatsRemaining.toString() + " SEAT REMAINING"
                          //     : seatsRemaining.toString() +
                          //     " SEATS REMAINING",
                          style: TagAlongTheme.lightTextTheme.overline,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ]
          )
        )
      )
      // child: Row(
      //   children: [
      //     Column(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         Text(ride.pickupLocation.city),
      //         Text(ride.dropoffLocation.city),
      //         Text(ride.driverId)
      //       ]
      //     )
      //   ]
      // )
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
              Expanded(
                child: Text(
                  // TODO: pickup / origin
                  ride.pickupLocation.city,
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
              Expanded(
                child: Text(
                  // TODO: destination,
                  ride.dropoffLocation.city,
                  style: TagAlongTheme.lightTextTheme.headline6,
                )
              ),
            ],
          ),
        ]
      )

    );
  }
}
