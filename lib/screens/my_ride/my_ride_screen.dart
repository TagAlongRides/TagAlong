import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/screens/my_ride/my_ride_detail_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:core/core.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({Key? key}) : super(key: key);
  static const routeName = '/my-ride-screen';

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  @override
  Widget build(BuildContext context) {
    final _tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    final _tagAlongUser = _tagAlongUserViewModel.tagAlongUser!;
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              // Always scrollable so pull-to-refresh works even when the list is short or empty
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FutureBuilder<List<RideModel>>(
                  future: RideRepository.instance.getAllRidesForUser(_tagAlongUser.id, ordered: true),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return const Text('You haven\'t offered or booked any rides yet!');
                      }
                      // Split once against a single "now" so every ride lands in exactly one section
                      final _now = DateTime.now();
                      final _upcomingRides =
                          snapshot.data!.where((ride) => ride.departureDateTime.isAfter(_now)).toList();
                      final _completedRides =
                          snapshot.data!.where((ride) => !ride.departureDateTime.isAfter(_now)).toList();

                      // Calculate upcoming ride earnings
                      var _upcomingEarnings = 0;
                      for (var ride in _upcomingRides) {
                        if (ride.driverId == _tagAlongUser.id && ride.status == RideStatus.scheduled) {
                          //TODO - Create a more robust way to manage the number of currently booked passengers
                          _upcomingEarnings += ride.price * (ride.noPassengers - ride.remainingSeats);
                        }
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Only display upcoming ride section if user has an upcoming ride
                          if (_upcomingEarnings > 0)
                            Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Estimated Earnings for Upcoming Rides: ',
                                          style: TagAlongTheme.lightTextTheme.headlineSmall!
                                              .copyWith(fontWeight: FontWeight.bold),
                                          softWrap: true,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${_upcomingEarnings.toString()}',
                                          style: TagAlongTheme.lightTextTheme.headlineSmall!
                                              .copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),

                          if (_upcomingRides.isNotEmpty) ...[
                            _sectionHeader('Upcoming'),
                            _rideList(_upcomingRides, _tagAlongUser.id),
                          ],
                          if (_completedRides.isNotEmpty) ...[
                            _sectionHeader('Completed'),
                            _rideList(_completedRides, _tagAlongUser.id),
                          ],
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TagAlongTheme.lightTextTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // The outer SingleChildScrollView does the scrolling, so the inner list must not scroll on its own
  Widget _rideList(List<RideModel> rides, String userId) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final _rideData = rides[index];
        final _isDriver = _rideData.driverId == userId;
        final _isCancelled =
            _rideData.status == RideStatus.canceled || (!_isDriver && !_rideData.riderIds.contains(userId));
        return MyRideTile(isDriver: _isDriver, isCancelled: _isCancelled, rideData: _rideData);
      },
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)), side: BorderSide(color: Colors.black54)),
        tileColor: _isCancelled ? Colors.grey[300] : Colors.white,
        leading: Icon(_isDriver ? FontAwesomeIcons.car : Icons.airline_seat_recline_normal_rounded),
        title: Text(
            _rideData.toCampus ? 'To ' + _rideData.dropoffLocation.label! : 'From ' + _rideData.pickupLocation.label!),
        subtitle: Text(DateFormat('EEE, MMM d').format(_rideData.departureDateTime)),
        trailing: _isCancelled
            ? Text(
                'Cancelled',
                style: TagAlongTheme.lightTextTheme.titleMedium,
              )
            : null,
        onTap: () {
          Navigator.of(context).pushNamed(MyRideDetailScreen.routeName, arguments: _rideData);
        },
      ),
    );
  }
}
