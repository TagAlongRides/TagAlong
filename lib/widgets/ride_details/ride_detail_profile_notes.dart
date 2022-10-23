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
  }) : super(key: key);

  final BuildContext context;
  final RideModel ride;
  // TODO - Implement UI changes based on these vars
  final bool isDriver;
  final bool isInFuture;
  final bool isMyRides;

  @override
  State<RideDetailProfileNotes> createState() => _RideDetailProfileNotesState();
}

class _RideDetailProfileNotesState extends State<RideDetailProfileNotes> {
  var _showPhone = false;
  String? _driverPhone;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (widget.isDriver) {
    //   List<RideBookingModel> _rideBookings =
    //       await RideBookingRepository.instance.getRideBookingForRideId(widget.ride.rideId);
    //   List<TagAlongUser> _riderData = [];
    //   for (var booking in _rideBookings) {
    //     var user = await Provider.of<TagAlongUserViewModel>(context).getUserFromID(booking.userId);
    //     _riderData.add(user!);
    //   }
    //   // final riderData = Provider.of<TagAlongUser>(context, listen: false);
    // }
  }

  Future<List<TagAlongUser>?> _getBookedUsers() async {
    List<TagAlongUser>? _riderData = [];
    if (widget.isDriver) {
      List<RideBookingModel> _rideBookings =
          await RideBookingRepository.instance.getRideBookingForRideId(widget.ride.rideId);
      for (var booking in _rideBookings) {
        var user = await Provider.of<TagAlongUserViewModel>(context).getUserFromID(booking.userId);
        _riderData.add(user!);
      }
      log.log.fine('_riderData: $_riderData');
      return _riderData;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    log.log.fine('isDriver: ${widget.isDriver}');
    return FutureBuilder(
      future: _getBookedUsers(),
      builder: (context, snapshot) => Container(
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

          // Ride Notes
          if (widget.ride.notes != "") const SizedBox(height: 16),

          if (widget.ride.notes != "")
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

          if (widget.isMyRides && !widget.isDriver && widget.isInFuture)
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Divider(thickness: 1),
          )
        ]),
      ),
    );
  }
}
