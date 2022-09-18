import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({Key? key}) : super(key: key);

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  @override
  Widget build(BuildContext context) {
    final _tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    final tagAlongUser = _tagAlongUserViewModel.tagAlongUser!;
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: FutureBuilder<List<RideBookingModel>>(
                future: RideBookingRepository.instance.getRideBookingForUser(tagAlongUser.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final rideBooking = snapshot.data![index];
                        return Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(rideBooking.rideBookingId),
                              LoadingButton(
                                  onPressed: () async {
                                    final ride = await RideRepository.instance.getRideById(rideBooking.rideId);
                                    if (ride.departureDateTime.difference(DateTime.now()).inHours > 6) {
                                      InfoDialog.show(
                                        context,
                                        message: 'Are you sure you want to cancel the ride ? Refund = true',
                                        positiveLabel: 'Continue',
                                        positivePress: () async {
                                          // 1. Init the refund from the stripe side
                                          final refund = await StripeRefundRepository.instance.refundDestinationCharge(
                                            StripeRefundRequest(
                                              charge: rideBooking.chargeId,
                                              reverseTransfer: true,
                                              refundApplicationFee: true,
                                            ),
                                          );

                                          // 2. Update the firebase collection to cancel the ride booking
                                          final ridebookingUpdated =
                                              await RideBookingRepository.instance.cancelRideBooking(rideBooking);

                                          // 3. Increment remainingSeats by 1 and update in Firebase
                                          ride.remainingSeats++;
                                          await RideRepository.instance.updateRide(ride);

                                          setState(() {});

                                          Navigator.of(context).pop();
                                        },
                                      );
                                    } else {
                                      // TODO - Prevent user from being able to cancel within 6 hours
                                      InfoDialog.show(context,
                                          message: 'Are you sure you want to cancel the ride ? Refund = false',
                                          positiveLabel: 'Continue', positivePress: () async {
                                        /// 1. Update the firebase collection to cancel the ride booking
                                        final ridebookingUpdated =
                                            await RideBookingRepository.instance.cancelRideBooking(rideBooking);

                                        setState(() {});

                                        Navigator.of(context).pop();
                                      });
                                    }
                                    // final message =
                                  },
                                  text: 'Cancel')
                            ],
                          ),
                        );
                      },
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
          const Text('My Offered Ride'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: FutureBuilder<List<RideModel>>(
                future: RideRepository.instance.getMyOfferedRides(tagAlongUser.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final ride = snapshot.data![index];
                        return Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(ride.rideId),
                              LoadingButton(
                                onPressed: () async {
                                  InfoDialog.show(context,
                                      message:
                                          'Are you sure you want to cancel the ride ? This action will cancel the ride and refund to all riders',
                                      positiveLabel: 'Continue', positivePress: () async {
                                    /// Get all active(cancel=false) ride booking from hte ride
                                    final rideBookings = await RideBookingRepository.instance
                                        .getRideBookingForRideId(ride.rideId, isCanceled: false);

                                    /// Refund for all active ride booking
                                    rideBookings.forEach((element) async {
                                      final refund = await StripeRefundRepository.instance.refundDestinationCharge(
                                        StripeRefundRequest(
                                          charge: element.chargeId,
                                          reverseTransfer: true,
                                          refundApplicationFee: true,
                                        ),
                                      );
                                    });

                                    /// Cancel the ride
                                    await RideRepository.instance.cancelRide(ride);
                                    setState(() {});

                                    Navigator.of(context).pop();
                                  });
                                },
                                text: 'Cancel',
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
