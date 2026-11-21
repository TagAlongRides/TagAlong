import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as log;
import 'package:tagalong/widgets/common/tagalong_components.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_misc.dart';
import 'package:url_launcher/url_launcher.dart';

/// The people on a ride: the driver (as seen by a passenger) or the booked
/// passengers (as seen by the driver), plus the driver's notes. With
/// [showFacts] it also lists the car and luggage allowance.
class RideDetailProfileNotes extends StatefulWidget {
  const RideDetailProfileNotes({
    Key? key,
    required this.context,
    required this.ride,
    this.isDriver = false,
    this.isInFuture = true,
    this.isMyRides = false,
    this.isCancelled = false,
    this.showFacts = false,
  }) : super(key: key);

  final BuildContext context;
  final RideModel ride;
  final bool isDriver;
  final bool isInFuture;
  final bool isMyRides;
  final bool isCancelled;
  final bool showFacts;

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
        final showNotes = widget.isInFuture && widget.ride.notes != '';

        return TagAlongCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isDriver) _driverProfile(participants.driver, loading),
              if (widget.isDriver)
                loading ? const Center(child: CircularProgressIndicator()) : _passengerList(participants.passengers),
              if (widget.showFacts) ...[
                const SizedBox(height: 14),
                RideDetailMisc(ride: widget.ride),
              ],
              if (showNotes) ...[
                const SizedBox(height: 14),
                _notes(),
              ],
              if (widget.isMyRides && !widget.isDriver && widget.isInFuture && !widget.isCancelled) ...[
                const SizedBox(height: 14),
                _driverPhoneButton(participants.driver),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Driver's picture, name, and a deep link to their Facebook profile.
  Widget _driverProfile(TagAlongUser? driver, bool loading) {
    final profileUrl = driver?.facebookProfileUrl;
    return Row(
      children: [
        TagAlongAvatar(name: widget.ride.driverFullName, imageUrl: widget.ride.driverProfilePictureUrl, size: 48),
        const SizedBox(width: TagAlongSpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.ride.getFirstNameAndInitial(), style: TagAlongText.titleSmall),
              const SizedBox(height: 2),
              Text('Your driver', style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
            ],
          ),
        ),
        // Disabled while we look the driver up, and for drivers who signed up
        // with a provider other than Facebook.
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4),
          ),
          onPressed: loading || profileUrl == null ? null : () => _openFacebookProfile(profileUrl),
          icon: const FaIcon(FontAwesomeIcons.facebook, size: 16),
          label: const Text('Profile'),
        ),
      ],
    );
  }

  /// The riders booked onto this trip, shown to the driver.
  Widget _passengerList(List<TagAlongUser> passengers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TagAlongSectionHeader(title: 'Passengers', count: '${passengers.length}'),
        const SizedBox(height: TagAlongSpace.s3),
        if (passengers.isEmpty)
          Text('No one has booked a seat yet.',
              style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary)),
        for (final passenger in passengers)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TagAlongSpace.s1),
            child: Row(
              children: [
                TagAlongAvatar(
                  name: '${passenger.firstName} ${passenger.lastName}',
                  imageUrl: passenger.profilePictureUrl,
                ),
                const SizedBox(width: TagAlongSpace.s3),
                // First name, last initial for each rider
                Expanded(
                  child: Text(
                    passenger.lastName.isEmpty
                        ? passenger.firstName
                        : '${passenger.firstName} ${passenger.lastName[0]}.',
                    style: TagAlongText.titleSmall,
                  ),
                ),
                if (widget.isInFuture)
                  OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(passenger.phoneNumber, 'Phone number'),
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: Text(passenger.phoneNumber),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _notes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: TagAlongColors.canvas, borderRadius: TagAlongRadius.mdAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TagAlongOverline('Notes from the driver'),
          const SizedBox(height: TagAlongSpace.s1),
          Text(widget.ride.notes, style: TagAlongText.bodyMedium),
        ],
      ),
    );
  }

  /// Reveals the driver's phone number to a booked passenger, then lets them
  /// copy it.
  Widget _driverPhoneButton(TagAlongUser? driver) {
    if (!_showPhone) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
          onPressed: () => setState(() {
            _driverPhone = driver?.phoneNumber;
            _showPhone = true;
          }),
          icon: const Icon(Icons.phone_outlined, size: 18),
          label: const Text('Show driver phone number'),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        onPressed: () => _copyToClipboard(_driverPhone ?? '', 'Phone number'),
        icon: const Icon(Icons.verified_outlined, size: 18, color: TagAlongColors.successInk),
        label: Text('Verified phone: ${_driverPhone ?? ''}'),
      ),
    );
  }
}
