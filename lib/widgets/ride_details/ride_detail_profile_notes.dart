import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as log;

class RideDetailProfileNotes extends StatefulWidget {
  const RideDetailProfileNotes({
    Key? key,
    required this.context,
    required this.ride,
    this.isDriver = false,
    this.isInFuture = true,
    this.isMyRides = false,
    this.isCancelled = false,
  }) : super(key: key);

  final BuildContext context;
  final RideModel ride;
  final bool isDriver;
  final bool isInFuture;
  final bool isMyRides;
  final bool isCancelled;

  @override
  State<RideDetailProfileNotes> createState() => _RideDetailProfileNotesState();
}

class _RideDetailProfileNotesState extends State<RideDetailProfileNotes> {
  var _showPhone = false;
  String? _driverPhone;

  Future<List<TagAlongUser>?> _getBookedUsers() async {
    var provider = Provider.of<TagAlongUserViewModel>(context);
    List<TagAlongUser>? _riderData = [];
    if (widget.isDriver) {
      List<RideBookingModel> _rideBookings =
          await RideBookingRepository.instance.getRideBookingForRideId(widget.ride.rideId);

      log.log.fine('Bookings: ${_rideBookings.toString()}');

      TagAlongUser? user;
      for (var booking in _rideBookings) {
        user = await provider.getUserFromID(booking.userId);
        _riderData.add(user!);
      }
      return _riderData;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    log.log.fine('isDriver: ${widget.isDriver}');
    return FutureBuilder(
        future: _getBookedUsers(),
        builder: (context, riders) {
          final riderData = riders.data as List<TagAlongUser>;
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
            child: Column(children: [
              if (!widget.isDriver)
                // Profile picture and Deep-link Facebook Button
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(widget.ride.driverProfilePictureUrl),
                            ),
                          ),
                          Text(widget.ride.getFirstNameAndInitial(), style: Theme.of(context).textTheme.headline6),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Respond to button press
                      },
                      icon: const FaIcon(FontAwesomeIcons.facebook),
                      label: const Text("View Profile"),
                      style: TagAlongTheme.outlinedButtonTheme.style,
                    )
                  ],
                ),
              if (widget.isDriver)
                riders.connectionState == ConnectionState.waiting
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Passengers:',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            if (riderData.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'No passengers',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            if (riderData.isNotEmpty)
                              ...riderData.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Expanded(
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 16.0),
                                                child: CircleAvatar(backgroundImage: NetworkImage(e.profilePictureUrl)),
                                              ),
                                              // Get first name, last initial for each rider
                                              Text("${e.firstName} ${e.lastName[0]}.",
                                                  style: Theme.of(context).textTheme.bodyLarge),
                                              if (widget.isInFuture)
                                                Expanded(
                                                  child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child: OutlinedButton(
                                                        onPressed: () async {
                                                          await Clipboard.setData(ClipboardData(text: e.phoneNumber))
                                                              .then((_) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(
                                                                content: Text("Phone number copied to clipboard"),
                                                                duration: Duration(seconds: 1),
                                                              ),
                                                            );
                                                          });
                                                        },
                                                        child: Text(
                                                          e.phoneNumber,
                                                          // style: TextStyle(color: Colors.black),
                                                        )),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),

              // Ride Notes
              if (widget.isInFuture && widget.ride.notes != "") const SizedBox(height: 16),

              if (widget.isInFuture && widget.ride.notes != "")
                Container(
                  padding: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  child: Text(widget.ride.notes),
                  // color: Colors.grey.shade50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),

              if (widget.isMyRides && !widget.isDriver && widget.isInFuture && !widget.isCancelled)
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  width: MediaQuery.of(context).size.width,
                  child: TextButton.icon(
                    style: TagAlongTheme.textButtonTheme.style!.copyWith(
                      backgroundColor: MaterialStateProperty.all(_showPhone ? Colors.white : Colors.lightBlue.shade50),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade500),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(1000)), // Set huge value to get pill-shaped button
                        ),
                      ),
                    ),
                    onPressed: !_showPhone
                        ? () async {
                            final driver = await Provider.of<TagAlongUserViewModel>(context, listen: false)
                                .getUserFromID(widget.ride.driverId);
                            setState(() {
                              _driverPhone = driver?.phoneNumber;
                              _showPhone = true;
                            });
                          }
                        : () async {
                            await Clipboard.setData(ClipboardData(text: _driverPhone)).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Phone number copied to clipboard"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            });
                          },
                    icon: Icon(
                      _showPhone ? Icons.verified_outlined : Icons.phone,
                      color: _showPhone ? Colors.blue : Colors.black,
                    ),
                    label: Text(_showPhone ? 'Verified Phone Number: $_driverPhone' : 'Show driver phone number'),
                  ),
                ),
              // Horizontal Divider
              Padding(
                padding: const EdgeInsets.all(16),
                child: !widget.isDriver && widget.isInFuture ? const Divider(thickness: 1) : null,
              )
            ]),
          );
        });
  }
}
