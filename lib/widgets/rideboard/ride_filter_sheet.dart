import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/viewmodels/filter_ride_view_model.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// The full filter sheet: date range, time of day and the off-campus stop.
///
/// Direction is not in here any more; the segmented control on the board sets
/// it, and the sheet keeps whatever the board has.
class RideFilterSheet extends StatelessWidget {
  const RideFilterSheet({Key? key}) : super(key: key);

  /// Opens the sheet showing the filters currently applied to the board.
  static Future<void> show(BuildContext context) {
    final board = Provider.of<RideBoardViewModel>(context, listen: false);
    final sheet = Provider.of<FilterRideViewModel>(context, listen: false);
    sheet.loadFrom(board.filters);
    _loadDestinationOptions(board, sheet);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RideFilterSheet(),
    );
  }

  /// Off-campus stops for the board's direction, or for both directions when
  /// the board shows everything.
  static Future<void> _loadDestinationOptions(RideBoardViewModel board, FilterRideViewModel sheet) async {
    sheet.setLoadingDestinations(true);
    final direction = board.filters.toCampus;
    final List<String> options;
    if (direction != null) {
      options = await board.getDestinationOptions(toCampus: direction);
    } else {
      final both = await Future.wait([
        board.getDestinationOptions(toCampus: true),
        board.getDestinationOptions(toCampus: false),
      ]);
      options = ({...both[0], ...both[1]}.toList())..sort();
    }
    sheet.setDestinationOptions(options);
  }

  @override
  Widget build(BuildContext context) {
    final board = Provider.of<RideBoardViewModel>(context, listen: false);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Consumer<FilterRideViewModel>(
          builder: (context, sheet, child) {
            final towardCampus = board.filters.toCampus;
            final stopLabel = towardCampus == null
                ? 'Off-campus stop'
                : towardCampus
                    ? 'Where are you coming from?'
                    : 'Where are you going?';

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(TagAlongSpace.gutter, 0, TagAlongSpace.gutter, TagAlongSpace.s6),
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Filters', style: TagAlongText.titleLarge)),
                          TagAlongIconButton(
                            icon: Icons.close_rounded,
                            tooltip: 'Close',
                            color: TagAlongColors.subtle,
                            size: 40,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: TagAlongSpace.s6),

                      // When
                      const TagAlongOverline('When are you leaving?'),
                      const SizedBox(height: TagAlongSpace.s2),
                      TextFormField(
                        readOnly: true,
                        enableInteractiveSelection: false,
                        decoration: InputDecoration(
                          hintText: sheet.departureRange == null ? 'Any date' : sheet.getFormattedDepartureDate(),
                          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                          suffixIcon: sheet.departureRange == null
                              ? null
                              : IconButton(
                                  tooltip: 'Clear dates',
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () => sheet.updateDepartureRange(null),
                                ),
                        ),
                        onTap: () async {
                          final now = DateTime.now();
                          final range = await showDateRangePicker(
                            context: context,
                            initialDateRange: sheet.departureRange,
                            firstDate: DateTime(now.year, now.month, now.day),
                            // Drivers can post up to 6 months out.
                            lastDate: now.add(const Duration(days: 190)),
                            helpText: 'Select when you want to leave',
                          );
                          if (range != null) sheet.updateDepartureRange(range);
                        },
                      ),
                      const SizedBox(height: TagAlongSpace.s6),

                      // Time of day
                      const TagAlongOverline('Time of day'),
                      const SizedBox(height: TagAlongSpace.s2),
                      Wrap(
                        spacing: TagAlongSpace.s2,
                        children: [
                          TagAlongFilterChip(
                            label: 'Day',
                            icon: Icons.wb_sunny_outlined,
                            selected: sheet.day,
                            onTap: sheet.toggleDay,
                          ),
                          TagAlongFilterChip(
                            label: 'Night',
                            icon: Icons.nightlight_outlined,
                            selected: sheet.night,
                            onTap: sheet.toggleNight,
                          ),
                        ],
                      ),
                      const SizedBox(height: TagAlongSpace.s2),
                      Text(
                        'Day is 6:00am - 5:59pm, night is 6:00pm - 5:59am. Pick both or neither to see all times.',
                        style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
                      ),
                      const SizedBox(height: TagAlongSpace.s6),

                      // Destination
                      TagAlongOverline(stopLabel),
                      const SizedBox(height: TagAlongSpace.s2),
                      if (sheet.loadingDestinations)
                        const Padding(
                          padding: EdgeInsets.all(TagAlongSpace.s4),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        DropdownButtonFormField<String?>(
                          value: sheet.destination,
                          isExpanded: true,
                          borderRadius: TagAlongRadius.mdAll,
                          dropdownColor: TagAlongColors.surface,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.place_outlined, size: 20)),
                          hint: Text(sheet.destinationOptions.isEmpty ? 'No locations available' : 'Anywhere'),
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('Anywhere')),
                            ...sheet.destinationOptions.map(
                              (option) => DropdownMenuItem<String?>(value: option, child: Text(option)),
                            ),
                          ],
                          onChanged: sheet.destinationOptions.isEmpty ? null : sheet.updateDestination,
                        ),
                    ],
                  ),
                ),
                TagAlongStickyBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                          onPressed: () {
                            // Clear the selections but keep the loaded
                            // destination options (resetAll would drop them).
                            sheet.updateDepartureRange(null);
                            if (sheet.day) sheet.toggleDay();
                            if (sheet.night) sheet.toggleNight();
                            sheet.updateDestination(null);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: TagAlongSpace.s3),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // The sheet has no direction control, so carry the
                            // board's across rather than the sheet's default.
                            final direction = board.filters.toCampus;
                            board.updateFilters(
                              sheet.toRideFilters().copyWith(toCampus: direction, clearToCampus: direction == null),
                            );
                          },
                          child: const Text('Show rides'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
