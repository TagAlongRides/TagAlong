import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_hero.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_pricing.dart';
import 'package:tagalong/widgets/ride_details/ride_detail_profile_notes.dart';

/// A ride on the board, before booking: when and where, who is driving, the
/// price, and a sticky "Reserve seat" bar.
class RideDetails extends StatelessWidget {
  const RideDetails({Key? key}) : super(key: key);
  static const routeName = '/ride_details';

  @override
  Widget build(BuildContext context) {
    final ride = Provider.of<RideDetailsViewModel>(context, listen: false).ride;

    return Scaffold(
      appBar: const TagAlongTopBar(title: 'Ride details'),
      bottomNavigationBar: RideReserveBar(ride: ride),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s2, TagAlongSpace.gutter, TagAlongSpace.s6),
        children: [
          RideDetailHero(ride: ride),
          const SizedBox(height: TagAlongSpace.s4),
          RideDetailProfileNotes(context: context, ride: ride, showFacts: true),
          const SizedBox(height: TagAlongSpace.s4),
          RideDetailPricing(context: context, ride: ride),
        ],
      ),
    );
  }
}
