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
              child: SingleChildScrollView(
                child: FutureBuilder<List<RideModel>>(
                  future: RideRepository.instance.getAllRidesForUser(_tagAlongUser.id, ordered: true),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isEmpty) {
                        return const Text('You haven\'t offered or booked any rides yet!');
                      }
                      // Calculate upcoming ride earnings
                      var _upcomingEarnings = 0;
                      for (var ride in snapshot.data!) {
                        if (ride.driverId == _tagAlongUser.id &&
                            ride.status == RideStatus.scheduled &&
                            ride.departureDateTime.isAfter(DateTime.now())) {
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

                          if (snapshot.data!.where((ride) => ride.departureDateTime.isAfter(DateTime.now())).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Upcoming',
                                style: TagAlongTheme.lightTextTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),

                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final _rideData = snapshot.data![index];
                              final _isDriver = _rideData.driverId == _tagAlongUser.id;
                              final _isCancelled = _rideData.status == RideStatus.canceled ||
                                  (!_isDriver && !_rideData.riderIds.contains(_tagAlongUser.id));
                              if (_rideData.departureDateTime.isAfter(DateTime.now())) {
                                return MyRideTile(isDriver: _isDriver, isCancelled: _isCancelled, rideData: _rideData);
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Completed',
                              style: TagAlongTheme.lightTextTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final _rideData = snapshot.data![index];
                              final _isDriver = _rideData.driverId == _tagAlongUser.id;
                              final _isCancelled = _rideData.status == RideStatus.canceled ||
                                  (!_isDriver && !_rideData.riderIds.contains(_tagAlongUser.id));
                              // final rideBooking = snapshot.data![index];
                              if (_rideData.departureDateTime.isBefore(DateTime.now())) {
                                return MyRideTile(isDriver: _isDriver, isCancelled: _isCancelled, rideData: _rideData);
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
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
