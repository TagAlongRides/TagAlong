import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';
import 'package:tagalong/widgets/rideboard/rideboard_card.dart';

/// Top of a ride's detail page: direction, departure time and date, and the
/// route on a panel tinted by direction.
///
/// Both addresses can be copied so a passenger can paste them straight into a
/// maps app (Milestone 3, §2.1.2). The seat count shows "x of y seats left"
/// (Milestone 3, §2.1.1).
class RideDetailHero extends StatelessWidget {
  const RideDetailHero({Key? key, required this.ride, this.showSeats = true}) : super(key: key);

  final RideModel ride;
  final bool showSeats;

  static String _oneLine(Location l) => '${l.address}, ${l.city}, ${l.state} ${l.zip}';
  static String _short(Location l) => [l.address, if (l.city.isNotEmpty) l.city].where((s) => s.isNotEmpty).join(', ');

  Widget _copyButton(BuildContext context, Location location, String label) {
    return IconButton(
      tooltip: 'Copy $label',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.copy_rounded, size: 18, color: TagAlongColors.textTertiary),
      onPressed: () async {
        // A single line is friendlier to paste into a maps search box.
        await Clipboard.setData(ClipboardData(text: _oneLine(location)));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 1)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TagAlongSpace.s5),
      decoration: BoxDecoration(
        color: TagAlongColors.direction(ride.toCampus),
        borderRadius: TagAlongRadius.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TagAlongTag(label: ride.toCampus ? 'To campus' : 'From campus', tone: TagTone.neutral),
              const Spacer(),
              if (showSeats)
                Text(
                  '${ride.remainingSeats} of ${ride.noPassengers} seats left',
                  style: TagAlongText.labelMedium.copyWith(color: TagAlongColors.directionInk(ride.toCampus)),
                ),
            ],
          ),
          const SizedBox(height: TagAlongSpace.s2),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 10,
            children: [
              Text(ride.departureTimeLabel, style: TagAlongText.displayLarge),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  DateFormat('EEE, MMM d').format(ride.departureDateTime),
                  style: TagAlongText.bodyLarge.copyWith(color: TagAlongColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: TagAlongSpace.s3),
          Container(
            padding: const EdgeInsets.fromLTRB(TagAlongSpace.s4, 14, TagAlongSpace.s1, 14),
            decoration: BoxDecoration(color: TagAlongColors.surface, borderRadius: TagAlongRadius.lgAll),
            child: TagAlongRouteTimeline(
              connectorHeight: 18,
              pickup: RouteStop(
                title: RideBoardCard.placeName(ride.pickupLocation),
                subtitle: _short(ride.pickupLocation),
                trailing: _copyButton(context, ride.pickupLocation, 'Pick-up location'),
              ),
              dropoff: RouteStop(
                title: RideBoardCard.placeName(ride.dropoffLocation),
                subtitle: _short(ride.dropoffLocation),
                trailing: _copyButton(context, ride.dropoffLocation, 'Drop-off location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
