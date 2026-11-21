import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/screens/my_ride/my_ride_detail_screen.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/pricing.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// Rides the user is driving or has booked, upcoming then completed.
class MyRideScreen extends StatefulWidget {
  const MyRideScreen({Key? key, this.onFindRide, this.onOfferRide, this.loadRides}) : super(key: key);
  static const routeName = '/my-ride-screen';

  /// Called by the empty state's "Find a ride" button. Pops back when null.
  final VoidCallback? onFindRide;

  /// Called by the empty state's "Offer a ride" button. Hidden when null.
  final VoidCallback? onOfferRide;

  /// Fetches the user's rides. Defaults to [RideRepository]; previews and
  /// tests pass sample data instead.
  @visibleForTesting
  final Future<List<RideModel>> Function(String userId)? loadRides;

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  late Future<List<RideModel>> _rides;

  @override
  void initState() {
    super.initState();
    _rides = _load();
  }

  Future<List<RideModel>> _load() {
    final user = Provider.of<TagAlongUserViewModel>(context, listen: false).tagAlongUser!;
    return widget.loadRides?.call(user.id) ?? RideRepository.instance.getAllRidesForUser(user.id, ordered: true);
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _rides = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<TagAlongUserViewModel>(context, listen: false).tagAlongUser!.id;
    final bottomInset = MediaQuery.paddingOf(context).bottom + TagAlongSpace.s4;

    final content = FutureBuilder<List<RideModel>>(
      future: _rides,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _scrollable([
            const TagAlongPageHeader(title: 'My Rides'),
            const SizedBox(height: TagAlongSpace.s8),
            Text('We couldn’t load your rides. Pull down to try again.',
                style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary)),
          ], bottomInset);
        }
        if (!snapshot.hasData) {
          return _scrollable([
            const TagAlongPageHeader(title: 'My Rides'),
            const SizedBox(height: TagAlongSpace.s10),
            const Center(child: CircularProgressIndicator()),
          ], bottomInset);
        }

        final rides = snapshot.data!;
        if (rides.isEmpty) {
          return _scrollable([
            const TagAlongPageHeader(title: 'My Rides'),
            _EmptyState(
              onFindRide: widget.onFindRide ?? () => Navigator.of(context).maybePop(),
              onOfferRide: widget.onOfferRide,
            ),
          ], bottomInset);
        }

        // Split once against a single "now" so every ride lands in exactly one section
        final now = DateTime.now();
        final upcoming = rides.where((ride) => ride.departureDateTime.isAfter(now)).toList();
        final completed = rides.where((ride) => !ride.departureDateTime.isAfter(now)).toList();

        final drivingUpcoming =
            upcoming.where((r) => r.driverId == userId && r.status == RideStatus.scheduled).toList();
        final ridingUpcoming = upcoming.where((r) => r.driverId != userId && !_isCancelled(r, userId)).length;

        // Estimated earnings for upcoming rides
        var earnings = 0;
        var bookedSeats = 0;
        for (final ride in drivingUpcoming) {
          //TODO - Create a more robust way to manage the number of currently booked passengers
          final booked = ride.noPassengers - ride.remainingSeats;
          bookedSeats += booked;
          earnings += ride.price * booked;
        }

        final summary = [
          if (drivingUpcoming.isNotEmpty) '${drivingUpcoming.length} driving',
          if (ridingUpcoming > 0) '$ridingUpcoming riding',
        ].join(' · ');

        return _scrollable([
          TagAlongPageHeader(title: 'My Rides', subtitle: summary.isEmpty ? null : '$summary coming up'),
          if (earnings > 0) ...[
            const SizedBox(height: TagAlongSpace.s4),
            _EarningsHero(earnings: earnings, bookedSeats: bookedSeats, rides: drivingUpcoming.length),
          ],
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: TagAlongSpace.s6),
            TagAlongSectionHeader(title: 'Upcoming', count: '${upcoming.length}'),
            const SizedBox(height: TagAlongSpace.s3),
            ..._tiles(upcoming, userId),
          ],
          if (completed.isNotEmpty) ...[
            const SizedBox(height: TagAlongSpace.s6),
            TagAlongSectionHeader(title: 'Completed', count: '${completed.length}'),
            const SizedBox(height: TagAlongSpace.s3),
            ..._tiles(completed, userId),
          ],
        ], bottomInset);
      },
    );

    return RefreshIndicator(onRefresh: _refresh, child: content);
  }

  static bool _isCancelled(RideModel ride, String userId) {
    final isDriver = ride.driverId == userId;
    return ride.status == RideStatus.canceled || (!isDriver && !ride.riderIds.contains(userId));
  }

  List<Widget> _tiles(List<RideModel> rides, String userId) {
    return [
      for (var i = 0; i < rides.length; i++) ...[
        if (i > 0) const SizedBox(height: 10),
        MyRideTile(
          isDriver: rides[i].driverId == userId,
          isCancelled: _isCancelled(rides[i], userId),
          rideData: rides[i],
        ),
      ],
    ];
  }

  /// Always scrollable so pull-to-refresh works even when the list is short or empty.
  Widget _scrollable(List<Widget> children, double bottomInset) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        TagAlongSpace.gutter,
        MediaQuery.paddingOf(context).top + TagAlongSpace.s2,
        TagAlongSpace.gutter,
        bottomInset,
      ),
      children: children,
    );
  }
}

/// Lavender-to-peach card with the driver's estimated upcoming earnings.
class _EarningsHero extends StatelessWidget {
  const _EarningsHero({required this.earnings, required this.bookedSeats, required this.rides});

  final int earnings;
  final int bookedSeats;
  final int rides;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TagAlongSpace.s5),
      decoration: BoxDecoration(
        borderRadius: TagAlongRadius.xlAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [TagAlongColors.brandSoft, TagAlongColors.toCampus],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: TagAlongOverline('Estimated earnings')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s2, vertical: TagAlongSpace.s1),
                decoration: BoxDecoration(color: TagAlongColors.surface, borderRadius: TagAlongRadius.pill),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 14),
                    const SizedBox(width: TagAlongSpace.s1),
                    Text('Paid out daily', style: TagAlongText.labelMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: TagAlongSpace.s1),
          Text(Pricing.format(earnings.toDouble()), style: TagAlongText.hero),
          const SizedBox(height: TagAlongSpace.s1),
          Text(
            '$bookedSeats booked ${bookedSeats == 1 ? 'seat' : 'seats'} across $rides upcoming '
            '${rides == 1 ? 'ride' : 'rides'} you’re driving',
            style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A ride in My Rides: calendar block tinted by direction, the trip and your
/// role in words, and your earnings, fare or a status tag on the right.
class MyRideTile extends StatelessWidget {
  const MyRideTile({
    Key? key,
    required bool isDriver,
    required bool isCancelled,
    required RideModel rideData,
  })  : _isDriver = isDriver,
        _isCancelled = isCancelled,
        _rideData = rideData,
        super(key: key);

  final bool _isDriver;
  final bool _isCancelled;
  final RideModel _rideData;

  static String _place(Location location) => (location.label ?? location.city).toTitleCase() as String;

  @override
  Widget build(BuildContext context) {
    final ride = _rideData;
    final isPast = !ride.departureDateTime.isAfter(DateTime.now());
    final booked = ride.noPassengers - ride.remainingSeats;
    final riders = '$booked ${booked == 1 ? 'rider' : 'riders'}';

    final title = ride.toCampus ? 'To ${_place(ride.dropoffLocation)}' : 'From ${_place(ride.pickupLocation)}';
    final role = _isDriver
        ? (isPast ? 'You drove · $riders' : 'Driving · $riders')
        : 'Riding with ${ride.getFirstNameAndInitial()}';
    final subtitle = '${ride.departureTimeLabel} · $role';

    final Color blockColor;
    Widget? trailing;
    if (_isCancelled) {
      blockColor = TagAlongColors.surface;
      trailing = const TagAlongTag(label: 'Cancelled', tone: TagTone.rose);
    } else if (isPast) {
      blockColor = TagAlongColors.subtle;
      trailing = const TagAlongTag(label: 'Completed', tone: TagTone.mint);
    } else {
      blockColor = TagAlongColors.direction(ride.toCampus);
      if (_isDriver) {
        final earned = ride.price * booked;
        if (earned > 0) {
          trailing = Text('+${Pricing.format(earned.toDouble())}',
              style: TagAlongText.labelLarge.copyWith(color: TagAlongColors.successInk));
        }
      } else {
        trailing = Text(Pricing.format(Pricing.total(ride.price)), style: TagAlongText.labelLarge);
      }
    }

    return TagAlongCard(
      padding: const EdgeInsets.all(TagAlongSpace.s3),
      color: _isCancelled ? TagAlongColors.canvas : TagAlongColors.surface,
      shadow: !_isCancelled,
      border: _isCancelled ? Border.all(color: TagAlongColors.border, width: 1.5) : null,
      onTap: () => Navigator.of(context).pushNamed(MyRideDetailScreen.routeName, arguments: ride),
      child: Row(
        children: [
          TagAlongDateBlock(date: ride.departureDateTime, color: blockColor),
          const SizedBox(width: TagAlongSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TagAlongText.titleSmall.copyWith(
                    color: _isCancelled ? TagAlongColors.textSecondary : TagAlongColors.textPrimary,
                  ),
                ),
                const SizedBox(height: TagAlongSpace.s1),
                Text(subtitle, style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: TagAlongSpace.s2), trailing],
        ],
      ),
    );
  }
}

/// "Nothing on the road yet" with an illustration and the two ways to start.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onFindRide, this.onOfferRide});

  final VoidCallback onFindRide;
  final VoidCallback? onOfferRide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        children: [
          const SizedBox(width: 220, height: 180, child: _RoadIllustration()),
          const SizedBox(height: TagAlongSpace.s5),
          Text('Nothing on the road yet', style: TagAlongText.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: TagAlongSpace.s2),
          Text(
            'You haven\'t offered or booked any rides yet!',
            style: TagAlongText.bodyLarge.copyWith(color: TagAlongColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TagAlongSpace.s2),
          Text(
            'Grab a seat on a ride to campus, or post your own drive and split the cost.',
            style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TagAlongSpace.s6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onFindRide, child: const Text('Find a ride')),
          ),
          if (onOfferRide != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onOfferRide, child: const Text('Offer a ride')),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pastel blobs, a dotted route between two stops and a car chip.
class _RoadIllustration extends StatelessWidget {
  const _RoadIllustration();

  @override
  Widget build(BuildContext context) {
    Widget blob(double size, Color color) =>
        Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 26, top: 6, child: blob(168, TagAlongColors.brandSoft)),
          Positioned(left: 160, top: 0, child: blob(64, TagAlongColors.toCampus)),
          Positioned(left: 6, top: 126, child: blob(40, TagAlongColors.success)),
          const Positioned(left: 35, top: 45, child: CustomPaint(size: Size(150, 90), painter: _RoutePainter())),
          Positioned(
            left: 78,
            top: 36,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: TagAlongColors.surface,
                shape: BoxShape.circle,
                boxShadow: TagAlongShadows.level2,
              ),
              child: const Icon(Icons.directions_car_outlined, size: 32, color: TagAlongColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = TagAlongColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Same curve as the Figma illustration: M8 80 C40 80 40 20 75 20 S110 70 142 10
    final path = Path()
      ..moveTo(8, 80)
      ..cubicTo(40, 80, 40, 20, 75, 20)
      ..cubicTo(110, 20, 110, 70, 142, 10);

    // Dots every 10px along the path.
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        final pos = metric.getTangentForOffset(d)!.position;
        canvas.drawLine(pos, pos + const Offset(0.01, 0), ink);
      }
    }

    canvas.drawCircle(const Offset(8, 80), 7, Paint()..color = TagAlongColors.surface);
    canvas.drawCircle(const Offset(8, 80), 7, ink..strokeWidth = 3);
    canvas.drawCircle(const Offset(142, 10), 7, Paint()..color = TagAlongColors.textPrimary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
