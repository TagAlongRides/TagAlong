import 'package:flutter/material.dart';
import 'package:tagalong/themes/tagalong_theme.dart';

class RideDetailCancelledMessage extends StatelessWidget {
  const RideDetailCancelledMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TagAlongTheme.colorError,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Text(
        'Ride Cancelled',
        textAlign: TextAlign.center,
        style: TagAlongTheme.lightTextTheme.titleLarge!.copyWith(
          color: TagAlongTheme.colorHighEmphasis,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
