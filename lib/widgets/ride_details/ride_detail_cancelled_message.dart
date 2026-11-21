import 'package:flutter/material.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';

/// Rose notice at the top of a cancelled ride or booking.
class RideDetailCancelledMessage extends StatelessWidget {
  const RideDetailCancelledMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TagAlongSpace.s4),
      decoration: BoxDecoration(color: TagAlongPalette.rose100, borderRadius: TagAlongRadius.lgAll),
      child: Row(
        children: [
          const Icon(Icons.event_busy_outlined, color: TagAlongColors.errorInk),
          const SizedBox(width: TagAlongSpace.s3),
          Text('Ride cancelled', style: TagAlongText.titleSmall.copyWith(color: TagAlongColors.errorInk)),
        ],
      ),
    );
  }
}
