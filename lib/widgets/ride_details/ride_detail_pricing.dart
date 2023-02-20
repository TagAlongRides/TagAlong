import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/screens/stripe_payment/ride_stripe_payment_screen.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/widgets/rideboard/rideboard.dart';

class RideDetailPricing extends StatelessWidget {
  const RideDetailPricing({
    Key? key,
    required this.context,
    required this.ride,
    this.userId,
    this.isDriver = false,
    this.isInFuture = false,
    this.isMyRides = false,
    this.isCancelled = false,
  }) : super(key: key);

  final BuildContext context;
  final RideModel ride;
  final String? userId;
  final bool isDriver;
  final bool isInFuture;
  final bool isMyRides;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    var rideDetailsViewModel = Provider.of<RideDetailsViewModel>(context, listen: false);
    rideDetailsViewModel.instantiateRide(ride: ride);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (isDriver || !isInFuture)
            Text(
              isDriver ? (isInFuture ? 'Estimated Earnings' : 'Earnings') : (isInFuture ? '' : 'Receipt'),
              style: TagAlongTheme.lightTextTheme.headline6,
            ),
          const SizedBox(height: 16),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: isDriver
                ? [
                    const Text('Number of Passengers'),
                    //TODO - Create a more robust way to manage the number of currently booked passengers
                    Text('${ride.noPassengers - ride.remainingSeats}'),
                  ]
                : [
                    const Text('Subtotal'),
                    Text('\$${ride.price}'),
                  ],
          ),
          const SizedBox(height: 16),

          // Service Fee
          Row(
            children: isDriver
                ? [
                    const Text('Price per Passenger'),
                    Spacer(),
                    Text('\$${ride.price}'),
                  ]
                : [
                    const Text('Service Fee'),
                    if (isInFuture) const SizedBox(width: 16),
                    if (isInFuture)
                      IconButton(
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.info_outline),
                          onPressed: () async {
                            return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: const Text('Pricing Details'),
                                      content: const Text(
                                          'This fee helps support TagAlong’s platform and covers a broad range of operating costs including app maintenance and support.'),
                                      actions: <Widget>[
                                        TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context))
                                      ]);
                                });
                          }),
                    const Spacer(),
                    Text('\$${rideDetailsViewModel.getServiceFee()}'),
                  ],
          ),
          // "Continue" Button
          const SizedBox(height: 16),
          if (!isMyRides)
            Consumer<TagAlongUserViewModel>(
              builder: (context, user, child) {
                final _isVerified = user.isEmailVerified();
                return ElevatedButton(
                  style: _isVerified ? null : ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          _isVerified ? 'Continue' : 'Email Verification Needed',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _isVerified ? '\$${rideDetailsViewModel.getTotalPrice()}' : '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      )
                    ],
                  ),
                  onPressed: _isVerified
                      ? () {
                          if (user.tagAlongUser!.id == ride.driverId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cannot reserve a seat because you are the driver of this ride'),
                              ),
                            );
                            Navigator.of(context).pushNamed(RideBoardScreen.routeName);
                          } else if (ride.riderIds.contains(user.tagAlongUser!.id)) {
                            // print('already booked');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You have already reserved a seat on this ride'),
                              ),
                            );
                            Navigator.of(context).pushNamed(RideBoardScreen.routeName);
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) {
                                return RideStripePaymentScreen(ride: ride);
                              },
                            ));
                          }
                        }
                      : () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    title: const Text('Please verify email'),
                                    content: const Text(
                                        'To keep your travel safe, Tagalong requires every user to verify their email address before posting or booking a ride.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Resend Verification'),
                                        onPressed: () {
                                          user.sendEmailVerificationToUser();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Verification email sent to ${user.tagAlongUser?.emailAddress}'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ]);
                              });
                        },
                );
              },
            ),
          if (isMyRides)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isDriver ? 'Total Earnings' : 'Subtotal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      //TODO - Create a more robust way to manage the number of currently booked passengers
                      isDriver
                          ? '\$${(ride.noPassengers - ride.remainingSeats) * ride.price}'
                          : '\$${rideDetailsViewModel.getTotalPrice()}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          if (isMyRides && isInFuture && !isCancelled)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: LoadingButton(
                style: TagAlongTheme.elevatedButtonTheme.style!.copyWith(
                  backgroundColor: MaterialStateProperty.all(TagAlongTheme.colorError),
                  foregroundColor: MaterialStateProperty.all(TagAlongTheme.colorHighEmphasis),
                ),
                onPressed: () async {
                  final rideBookings = await RideBookingRepository.instance
                      .getBookingsForRideAndUser(rideId: ride.rideId, userId: userId!, isCanceled: false);
                  InfoDialog.show(
                    context,
                    message: isDriver
                        ? 'Are you sure you want to cancel the trip? This will refund all passengers and cannot be reversed.'
                        : 'Are you sure you want to cancel your reservation and give up your seat?',
                    positiveLabel: 'Confirm',
                    positivePress: _handleCancel,
                  );
                },
                text: isDriver ? 'Cancel Ride & Notify Riders' : 'Cancel Ride & Give Up My Seat',
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleCancel() async {
    /// Get all relevant bookings for the ride.
    /// For driver, this includes all bookings for the ride. For passenger, only return their own booking record(s).
    try {
      final rideBookings = isDriver
          ? await RideBookingRepository.instance.getRideBookingForRideId(
              ride.rideId,
              isCanceled: false,
            )
          : await RideBookingRepository.instance.getBookingsForRideAndUser(
              rideId: ride.rideId,
              userId: userId!,
              isCanceled: false,
            );

      // 1. Initiate Stripe refund for all relevant bookings
      rideBookings.forEach((element) async {
        final refund = await StripeRefundRepository.instance.refundDestinationCharge(
          StripeRefundRequest(
            charge: element.chargeId,
            reverseTransfer: true,
            refundApplicationFee: true,
          ),
        );
        // 2. Update ride bookings in Firebase to reflect cancellation
        await RideBookingRepository.instance.cancelRideBooking(element);
      });

      // 3. Update ride in Firebase to reflect cancellation
      if (!isDriver) {
        // Increment remainingSeats by 1
        // TODO - Create a more robust way to manage the number of currently booked passengers
        ride.remainingSeats++;
        ride.riderIds.removeWhere((rider) => rider == userId);

        await RideRepository.instance.updateRide(ride);
      } else if (isDriver) {
        // Cancel the ride
        await RideRepository.instance.cancelRide(ride);
      }
    } catch (e) {
      logger.log.finest(e.toString());
    }

    // Pop the dialog box and My Ride detail screen to return to main My Rides page
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}
