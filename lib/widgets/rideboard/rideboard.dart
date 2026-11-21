import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/account/notification_prefs_screen.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/ride_filters.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';
import 'package:tagalong/widgets/rideboard/ride_filter_sheet.dart';
import 'package:tagalong/widgets/rideboard/rideboard_card.dart';

/// The list of rides available to the signed-in user's school.
///
/// Shows the first page of rides and pages in more as the user reaches the
/// bottom of the list (Milestone 2, §10.5 - §10.6). The common filters
/// (direction, today/tomorrow, day/night) sit above the list; the rest are in
/// [RideFilterSheet].
class RideBoard extends StatefulWidget {
  const RideBoard({Key? key}) : super(key: key);

  @override
  State<RideBoard> createState() => _RideBoardState();
}

class _RideBoardState extends State<RideBoard> {
  final ScrollController _scrollController = ScrollController();
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Start the next page a little before the user hits the very bottom.
    if (position.pixels >= position.maxScrollExtent - 200) {
      Provider.of<RideBoardViewModel>(context, listen: false).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.log.fine('RideBoardList Build');

    // Watching the user view model as well, because the board can't query
    // until it knows which school to show (Milestone 2, §11.2.1) and the user
    // record may still be loading on the first frame.
    return Consumer2<TagAlongUserViewModel, RideBoardViewModel>(
      builder: (context, userViewModel, board, child) {
        if (board.setUniversity(userViewModel.tagAlongUser?.institution)) {
          // The school just became known, or changed. Reload after this frame
          // so we aren't mutating the view model mid-build.
          WidgetsBinding.instance.addPostFrameCallback((_) => board.refresh());
        }

        final bottomInset = MediaQuery.paddingOf(context).bottom + TagAlongSpace.s4;
        const gutter = EdgeInsets.symmetric(horizontal: TagAlongSpace.gutter);

        return RefreshIndicator(
          onRefresh: board.refresh,
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverSafeArea(
                bottom: false,
                sliver: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s2, TagAlongSpace.gutter, 0),
                  sliver: SliverList.list(
                    children: [
                      TagAlongPageHeader(
                        eyebrow: _greeting(userViewModel),
                        title: 'Where to today?',
                        trailing: TagAlongIconButton(
                          icon: Icons.notifications_none_rounded,
                          tooltip: 'Notification settings',
                          onPressed: () => Navigator.of(context).pushNamed(NotificationPrefsScreen.routeName),
                        ),
                      ),
                      if (!userViewModel.isEmailVerified() && !_bannerDismissed) ...[
                        const SizedBox(height: TagAlongSpace.s4),
                        _emailBanner(userViewModel),
                      ],
                      const SizedBox(height: TagAlongSpace.s5),
                      _searchPill(board.filters),
                      const SizedBox(height: TagAlongSpace.s5),
                      TagAlongSegmented(
                        labels: const ['All', 'To campus', 'From campus'],
                        selected: switch (board.filters.toCampus) { null => 0, true => 1, false => 2 },
                        onChanged: (i) => _setDirection(board, switch (i) { 1 => true, 2 => false, _ => null }),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _quickFilters(board)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    TagAlongSpace.gutter, TagAlongSpace.s5, TagAlongSpace.gutter, TagAlongSpace.s3),
                sliver: SliverToBoxAdapter(
                  child: TagAlongSectionHeader(
                    title: 'Leaving soon',
                    count: _countLabel(board),
                    action: _hasActiveFilters(board.filters) ? 'Clear filters' : null,
                    onAction: () => board.updateFilters(const RideFilters()),
                  ),
                ),
              ),
              ..._rideList(board, gutter),
              SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
            ],
          ),
        );
      },
    );
  }

  String _greeting(TagAlongUserViewModel userViewModel) {
    final name = userViewModel.tagAlongUser?.firstName ?? '';
    return name.isEmpty ? 'Hey there' : 'Hey, $name';
  }

  String? _countLabel(RideBoardViewModel board) {
    if (board.rides.isEmpty) return null;
    final n = board.rides.length;
    return '$n${board.hasMore ? '+' : ''} ${n == 1 ? 'ride' : 'rides'}';
  }

  // ---------------------------------------------------------------------------
  // Filters
  // ---------------------------------------------------------------------------

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

  /// Whether [filters] limits the board to exactly the day [day].
  bool _isOnlyDay(RideFilters filters, DateTime day) =>
      filters.departureDateStart == _startOfDay(day) && filters.departureDateEnd == _endOfDay(day);

  bool _hasActiveFilters(RideFilters f) => f != const RideFilters();

  /// Filters that only the sheet can set: a date range other than today or
  /// tomorrow, or a destination.
  bool _hasSheetOnlyFilters(RideFilters f) {
    final now = DateTime.now();
    final customDates =
        f.departureDateStart != null && !_isOnlyDay(f, now) && !_isOnlyDay(f, now.add(const Duration(days: 1)));
    return customDates || f.destination != null;
  }

  void _setDirection(RideBoardViewModel board, bool? toCampus) {
    if (board.filters.toCampus == toCampus) return;
    // The destination is the off-campus end, which depends on direction.
    board.updateFilters(
      board.filters.copyWith(toCampus: toCampus, clearToCampus: toCampus == null, clearDestination: true),
    );
  }

  void _toggleDay(RideBoardViewModel board, DateTime day) {
    final f = board.filters;
    board.updateFilters(_isOnlyDay(f, day)
        ? f.copyWith(clearDates: true)
        : f.copyWith(departureDateStart: _startOfDay(day), departureDateEnd: _endOfDay(day)));
  }

  Widget _searchPill(RideFilters filters) {
    final destination = filters.destination;
    return Container(
      decoration: BoxDecoration(boxShadow: TagAlongShadows.level1, borderRadius: TagAlongRadius.pill),
      child: Material(
        color: TagAlongColors.surface,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => RideFilterSheet.show(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(TagAlongSpace.s5, TagAlongSpace.s2, TagAlongSpace.s2, TagAlongSpace.s2),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 20, color: TagAlongColors.textSecondary),
                const SizedBox(width: TagAlongSpace.s3),
                Expanded(
                  child: Text(
                    destination ?? 'Pick a stop or destination',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TagAlongText.bodyLarge.copyWith(
                      color: destination == null ? TagAlongColors.textTertiary : TagAlongColors.textPrimary,
                    ),
                  ),
                ),
                Badge(
                  isLabelVisible: _hasSheetOnlyFilters(filters),
                  backgroundColor: TagAlongColors.brand,
                  smallSize: 10,
                  child: TagAlongIconButton(
                    icon: Icons.tune_rounded,
                    tooltip: 'All filters',
                    color: TagAlongColors.subtle,
                    size: 40,
                    onPressed: () => RideFilterSheet.show(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickFilters(RideBoardViewModel board) {
    final f = board.filters;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final chips = [
      TagAlongFilterChip(label: 'Today', selected: _isOnlyDay(f, now), onTap: () => _toggleDay(board, now)),
      TagAlongFilterChip(
          label: 'Tomorrow', selected: _isOnlyDay(f, tomorrow), onTap: () => _toggleDay(board, tomorrow)),
      TagAlongFilterChip(
        label: 'Day',
        icon: Icons.wb_sunny_outlined,
        selected: f.day,
        onTap: () => board.updateFilters(f.copyWith(day: !f.day)),
      ),
      TagAlongFilterChip(
        label: 'Night',
        icon: Icons.nightlight_outlined,
        selected: f.night,
        onTap: () => board.updateFilters(f.copyWith(night: !f.night)),
      ),
    ];
    return SizedBox(
      height: 36 + TagAlongSpace.s5,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s5, TagAlongSpace.gutter, 0),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: TagAlongSpace.s2),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // List
  // ---------------------------------------------------------------------------

  List<Widget> _rideList(RideBoardViewModel board, EdgeInsets gutter) {
    final rides = board.rides;

    // Still waiting to find out which school's board this is, or loading the
    // first page.
    if (!board.hasUniversity || (board.isLoading && rides.isEmpty)) {
      return [
        const SliverPadding(
          padding: EdgeInsets.all(TagAlongSpace.s10),
          sliver: SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
        ),
      ];
    }

    if (board.error != null && rides.isEmpty) {
      return [
        _message(Icons.wifi_off_rounded, 'Couldn’t load rides', 'Something went wrong. Pull down to try again.'),
      ];
    }

    if (rides.isEmpty) {
      return [
        _message(
          Icons.directions_car_outlined,
          'No rides here yet',
          _hasActiveFilters(board.filters)
              ? 'Nothing matches these filters right now. Try widening them, or pull down to refresh.'
              : 'No one has posted a ride yet. Pull down to refresh.',
        ),
      ];
    }

    return [
      SliverPadding(
        padding: gutter,
        sliver: SliverList.separated(
          itemCount: rides.length,
          separatorBuilder: (_, __) => const SizedBox(height: TagAlongSpace.s4),
          itemBuilder: (context, i) => RideBoardCard(ride: rides[i]),
        ),
      ),
      if (board.hasMore)
        const SliverPadding(
          padding: EdgeInsets.all(TagAlongSpace.s4),
          sliver: SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
        ),
    ];
  }

  Widget _message(IconData icon, String title, String body) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(TagAlongSpace.s8, TagAlongSpace.s8, TagAlongSpace.s8, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: TagAlongColors.brandSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: TagAlongColors.textPrimary),
            ),
            const SizedBox(height: TagAlongSpace.s4),
            Text(title, style: TagAlongText.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: TagAlongSpace.s2),
            Text(body,
                style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// Persistent prompt to confirm the user's .edu address (Milestone 2, §15).
  Widget _emailBanner(TagAlongUserViewModel userViewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(TagAlongSpace.s4, TagAlongSpace.s3, TagAlongSpace.s2, TagAlongSpace.s3),
      decoration: BoxDecoration(color: TagAlongPalette.butter100, borderRadius: TagAlongRadius.lgAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.mark_email_unread_outlined, size: 20, color: TagAlongColors.warningInk),
          ),
          const SizedBox(width: TagAlongSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Confirm your email', style: TagAlongText.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'You’ll need to confirm your school email before you can book a ride.',
                  style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textSecondary),
                ),
                const SizedBox(height: TagAlongSpace.s1),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    userViewModel.sendEmailVerificationToUser();
                    setState(() => _bannerDismissed = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification email sent to ${userViewModel.tagAlongUser?.emailAddress}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Resend confirmation email'),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Dismiss',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18, color: TagAlongColors.textSecondary),
            onPressed: () => setState(() => _bannerDismissed = true),
          ),
        ],
      ),
    );
  }
}
