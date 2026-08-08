import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:core/core.dart';

/// Pickup and dropoff for a ride. Both addresses can be copied to the
/// clipboard so a passenger can paste them straight into a maps app
/// (Milestone 3, §2.1.2).
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: Text(
                (ride.dropoffLocation.label ?? ride.dropoffLocation.city).toTitleCase() as String,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.right,
              ),
            )
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: _CopyableAddress(
                location: ride.pickupLocation,
                label: 'Pick-up location',
                alignment: CrossAxisAlignment.start,
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: _CopyableAddress(
                location: ride.dropoffLocation,
                label: 'Drop-off location',
                alignment: CrossAxisAlignment.end,
                textAlign: TextAlign.right,
              ),
            )
          ])
        ]));
  }
}

/// An address with a copy button beside it.
class _CopyableAddress extends StatelessWidget {
  const _CopyableAddress({
    Key? key,
    required this.location,
    required this.label,
    required this.alignment,
    required this.textAlign,
  }) : super(key: key);

  final Location location;
  final String label;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  String get _formatted => '${location.address}\n${location.city}, ${location.state} ${location.zip}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          _formatted,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: textAlign,
        ),
        TextButton.icon(
          onPressed: () async {
            // A single line is friendlier to paste into a maps search box than
            // the two-line form we display.
            await Clipboard.setData(
              ClipboardData(text: '${location.address}, ${location.city}, ${location.state} ${location.zip}'),
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label copied to clipboard'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.copy, size: 14),
          label: const Text('Copy', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
