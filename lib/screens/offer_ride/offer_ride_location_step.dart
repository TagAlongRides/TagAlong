import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/university_locations.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';
import 'package:tagalong/widgets/offer_ride/location_search_field.dart';

/// The pickup or dropoff step of Offer Ride.
///
/// One end of every ride is a fixed spot on campus, picked from a list; the
/// other is anywhere, found through Google Maps. Which is which depends on
/// the ride's direction.
class OfferRideLocationStep extends StatefulWidget {
  const OfferRideLocationStep({
    Key? key,
    required this.isPickup,
    required this.step,
    required this.totalSteps,
    required this.nextRoute,
  }) : super(key: key);

  final bool isPickup;
  final int step;
  final int totalSteps;
  final String nextRoute;

  @override
  State<OfferRideLocationStep> createState() => _OfferRideLocationStepState();
}

class _OfferRideLocationStepState extends State<OfferRideLocationStep> {
  final _searchKey = GlobalKey<LocationSearchFieldState>();
  bool _checking = false;
  bool _showCampusError = false;

  /// Whether this step is the campus end of the ride.
  bool _isCampusEnd(OfferRideViewModel vm) => widget.isPickup ? !vm.toCampus : vm.toCampus;

  Future<void> _continue(OfferRideViewModel vm) async {
    if (_isCampusEnd(vm)) {
      if (vm.campusSpot == null) {
        setState(() => _showCampusError = true);
        return;
      }
    } else {
      setState(() => _checking = true);
      final ok = await _searchKey.currentState?.resolve() ?? false;
      if (!mounted) return;
      setState(() => _checking = false);
      if (!ok) return;
    }
    logger.log.fine('Leaving Offer Ride ${widget.isPickup ? 'pickup' : 'dropoff'}');
    Navigator.pushNamed(context, widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OfferRideViewModel>(builder: (context, vm, _) {
      final campusEnd = _isCampusEnd(vm);
      final verb = widget.isPickup ? 'pick up' : 'drop off';
      return Scaffold(
        backgroundColor: TagAlongColors.canvas,
        appBar: TagAlongTopBar(
          title: 'Offer a ride',
          trailing: Center(
            child: Text('${widget.step}/${widget.totalSteps}',
                style: TagAlongText.labelMedium.copyWith(color: TagAlongColors.textTertiary)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
              TagAlongSpace.gutter, TagAlongSpace.s2, TagAlongSpace.gutter, TagAlongSpace.s10),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _StepProgress(step: widget.step, total: widget.totalSteps),
            const SizedBox(height: TagAlongSpace.s6),
            Align(alignment: Alignment.centerLeft, child: TagAlongTag.direction(vm.toCampus)),
            const SizedBox(height: TagAlongSpace.s3),
            Text('Where will you $verb passengers?', style: TagAlongText.titleLarge),
            const SizedBox(height: TagAlongSpace.s2),
            Text(
              campusEnd ? 'Choose a spot on campus.' : 'Search for an address or a place, like a station or a store.',
              style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary),
            ),
            const SizedBox(height: TagAlongSpace.s6),
            if (campusEnd)
              _CampusSpotList(
                selected: vm.campusSpot,
                accent: TagAlongColors.directionSoft(vm.toCampus),
                showError: _showCampusError,
                onSelected: (spot) {
                  setState(() => _showCampusError = false);
                  vm.updateCampusSpot(spot);
                },
              )
            else
              LocationSearchField(
                key: _searchKey,
                value: vm.offCampusPlace,
                accent: TagAlongColors.direction(vm.toCampus),
                onChanged: vm.updateOffCampusPlace,
              ),
          ],
        ),
        bottomNavigationBar: TagAlongStickyBar(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checking ? null : () => _continue(vm),
              child: _checking
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continue'),
            ),
          ),
        ),
      );
    });
  }
}

/// A thin segmented bar: filled up to [step].
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $step of $total',
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: TagAlongSpace.s1),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step ? TagAlongColors.brand : TagAlongColors.border,
                  borderRadius: TagAlongRadius.pill,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CampusSpotList extends StatelessWidget {
  const _CampusSpotList({
    required this.selected,
    required this.accent,
    required this.showError,
    required this.onSelected,
  });

  final String? selected;
  final Color accent;
  final bool showError;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final spots = VirginiaTechLocation.locationNames;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showError)
          Padding(
            padding: const EdgeInsets.only(bottom: TagAlongSpace.s3),
            child: Text('Choose where on campus',
                style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.errorInk)),
          ),
        TagAlongCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < spots.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: TagAlongSpace.s4, color: TagAlongColors.border),
                _CampusSpotRow(
                  name: spots[i],
                  address: VirginiaTechLocation.mappings[spots[i]]!,
                  selected: spots[i] == selected,
                  accent: accent,
                  onTap: () => onSelected(spots[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CampusSpotRow extends StatelessWidget {
  const _CampusSpotRow({
    required this.name,
    required this.address,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String name;
  final String address;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: selected ? accent : null,
          padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4, vertical: TagAlongSpace.s3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TagAlongText.labelLarge),
                    Text(address.split(',').first,
                        style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textSecondary)),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? TagAlongColors.brand : TagAlongColors.borderStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
