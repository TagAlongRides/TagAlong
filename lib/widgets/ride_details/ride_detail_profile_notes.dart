import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as log;
import 'package:url_launcher/url_launcher.dart';

/// The people on a ride: the driver (as seen by a passenger) or the booked
/// passengers (as seen by the driver), plus the driver's notes.
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

/// Everyone we need to render this section, loaded in one pass.
class _RideParticipants {
  const _RideParticipants({this.driver, this.passengers = const []});

  /// The user who is driving. Only loaded for the passenger's view, where we
  /// need their Facebook profile and phone number.
  final TagAlongUser? driver;

  /// Users who have booked a seat. Only loaded for the driver's view.
  final List<TagAlongUser> passengers;
}

class _RideDetailProfileNotesState extends State<RideDetailProfileNotes> {
  /// Built once in [initState] rather than in `build`, so rebuilds don't kick
  /// off a fresh round of Firestore reads.
  late final Future<_RideParticipants> _participants;

  var _showPhone = false;
  String? _driverPhone;

  @override
  void initState() {
    super.initState();
    _participants = _loadParticipants();
  }

  Future<_RideParticipants> _loadParticipants() async {
    final provider = Provider.of<TagAlongUserViewModel>(context, listen: false);

    if (widget.isDriver) {
      final bookings = await RideBookingRepository.instance.getRideBookingForRideId(widget.ride.rideId);
      log.log.fine('Bookings: ${bookings.toString()}');

      final passengers = <TagAlongUser>[];
      for (final booking in bookings) {
        final user = await provider.getUserFromID(booking.userId);
        if (user != null) {
          passengers.add(user);
        }
      }
      return _RideParticipants(passengers: passengers);
    }

    // Passenger's view - we only need the driver.
    return _RideParticipants(driver: await provider.getUserFromID(widget.ride.driverId));
  }

  /// Opens the driver's Facebook profile in the Facebook app, or the browser
  /// if it isn't installed (Milestone 3, §2.1.4.2).
  Future<void> _openFacebookProfile(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open this driver's Facebook profile")),
      );
    }
  }

  Future<void> _copyToClipboard(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log.log.fine('isDriver: ${widget.isDriver}');
    return FutureBuilder<_RideParticipants>(
      future: _participants,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final participants = snapshot.data ?? const _RideParticipants();

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          child: Column(children: [
            if (!widget.isDriver) _driverProfile(participants.driver, loading),
            if (widget.isDriver)
              loading ? const CircularProgressIndicator() : _passengerList(participants.passengers),

            // Ride Notes
            if (widget.isInFuture && widget.ride.notes != "") const SizedBox(height: 16),
            if (widget.isInFuture && widget.ride.notes != "") _notes(),

            if (widget.isMyRides && !widget.isDriver && widget.isInFuture && !widget.isCancelled)
              _driverPhoneButton(participants.driver),

            // Horizontal Divider
            Padding(
              padding: const EdgeInsets.all(16),
              child: !widget.isDriver && widget.isInFuture ? const Divider(thickness: 1) : null,
            )
          ]),
        );
      },
    );
  }

  /// Driver's picture, name, and a deep link to their Facebook profile.
  Widget _driverProfile(TagAlongUser? driver, bool loading) {
    final profileUrl = driver?.facebookProfileUrl;
    return Row(
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
              Text(widget.ride.getFirstNameAndInitial(), style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        OutlinedButton.icon(
          // Disabled while we look the driver up, and for drivers who signed
          // up with a provider other than Facebook.
          onPressed: loading || profileUrl == null ? null : () => _openFacebookProfile(profileUrl),
          icon: const FaIcon(FontAwesomeIcons.facebook),
          label: const Text("View Profile"),
          style: TagAlongTheme.outlinedButtonTheme.style,
        )
      ],
    );
  }

  /// The riders booked onto this trip, shown to the driver.
  Widget _passengerList(List<TagAlongUser> passengers) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Passengers:', style: Theme.of(context).textTheme.titleLarge),
          if (passengers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('No passengers', style: TextStyle(fontStyle: FontStyle.italic)),
            ),
          ...passengers.map((passenger) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(backgroundImage: NetworkImage(passenger.profilePictureUrl)),
                  ),
                  // Get first name, last initial for each rider
                  Text("${passenger.firstName} ${passenger.lastName[0]}.",
                      style: Theme.of(context).textTheme.bodyLarge),
                  if (widget.isInFuture)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => _copyToClipboard(passenger.phoneNumber, 'Phone number'),
                          child: Text(passenger.phoneNumber),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _notes() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width,
      child: Text(widget.ride.notes),
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
    );
  }

  /// Reveals the driver's phone number to a booked passenger, then lets them
  /// copy it.
  Widget _driverPhoneButton(TagAlongUser? driver) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      width: MediaQuery.of(context).size.width,
      child: TextButton.icon(
        style: TagAlongTheme.textButtonTheme.style!.copyWith(
          backgroundColor: MaterialStateProperty.all(_showPhone ? Colors.white : Colors.lightBlue.shade50),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade500),
              // Set huge value to get pill-shaped button
              borderRadius: const BorderRadius.all(Radius.circular(1000)),
            ),
          ),
        ),
        onPressed: !_showPhone
            ? () {
                setState(() {
                  _driverPhone = driver?.phoneNumber;
                  _showPhone = true;
                });
              }
            : () => _copyToClipboard(_driverPhone ?? '', 'Phone number'),
        icon: Icon(
          _showPhone ? Icons.verified_outlined : Icons.phone,
          color: _showPhone ? Colors.blue : Colors.black,
        ),
        label: Text(_showPhone ? 'Verified Phone Number: $_driverPhone' : 'Show driver phone number'),
      ),
    );
  }
}
