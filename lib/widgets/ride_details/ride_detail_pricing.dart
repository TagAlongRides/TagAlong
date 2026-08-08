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
import 'package:tagalong/util/pricing.dart';

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
              style: TagAlongTheme.lightTextTheme.titleLarge,
            ),
          const SizedBox(height: 16),

          if (isDriver) ..._driverEarnings(),

          // Passengers see the full price breakdown. Before booking it is
          // collapsed behind an expandable "Total price for 1 passenger"
          // header; on a receipt it is always open.
          if (!isDriver) _PriceBreakdown(ride: ride, alwaysExpanded: isMyRides),

          // "Pay with Credit Card or Debit Card" Button
          const SizedBox(height: 16),
          if (!isMyRides)
            Consumer<TagAlongUserViewModel>(
              builder: (context, user, child) {
                final _isVerified = user.isEmailVerified();
                return ElevatedButton(
                  style: _isVerified ? null : ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                  child: Text(
                    _isVerified ? 'Pay with Credit Card or Debit Card' : 'Email Verification Needed',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You have already reserved a seat on this ride'),
                              ),
                            );
                            Navigator.of(context).pushNamed(RideBoardScreen.routeName);
                          } else if (ride.remainingSeats <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sorry! This ride has no more seats remaining.'),
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
                                        'Heads up! In order to book a ride you’ll need to confirm your email. Would you like us to resend your confirmation email?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Yes, please!'),
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
                                        child: const Text('No, thanks.'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ]);
                              });
                        },
                );
              },
            ),

          if (isMyRides && isDriver)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Earnings', style: TextStyle(fontWeight: FontWeight.bold)),
                //TODO - Create a more robust way to manage the number of currently booked passengers
                Text(
                  '\$${(ride.noPassengers - ride.remainingSeats) * ride.price}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

  /// The driver's side of the ledger — headcount and per-passenger take.
  List<Widget> _driverEarnings() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Number of Passengers'),
          //TODO - Create a more robust way to manage the number of currently booked passengers
          Text('${ride.noPassengers - ride.remainingSeats}'),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Price per Passenger'),
          Text('\$${ride.price}'),
        ],
      ),
    ];
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

/// "Total price for 1 passenger" with an expandable breakdown of the driver's
/// price, the service fee, and taxes (Milestone 3, §2.1.3).
///
/// Collapsed by default when the passenger is deciding whether to book; a
/// receipt for an already-booked ride passes [alwaysExpanded] so the breakdown
/// is not hidden behind a tap.
class _PriceBreakdown extends StatefulWidget {
  const _PriceBreakdown({Key? key, required this.ride, this.alwaysExpanded = false}) : super(key: key);

  final RideModel ride;
  final bool alwaysExpanded;

  @override
  State<_PriceBreakdown> createState() => _PriceBreakdownState();
}

class _PriceBreakdownState extends State<_PriceBreakdown> {
  bool _expanded = false;

  bool get _isOpen => widget.alwaysExpanded || _expanded;

  @override
  Widget build(BuildContext context) {
    final price = widget.ride.price;
    // Expanding partitions the total from the rest of the page by making it
    // bold, per the requirements.
    final totalStyle = TextStyle(
      fontWeight: _isOpen ? FontWeight.bold : FontWeight.normal,
      fontSize: 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.alwaysExpanded ? null : () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text('Total price for 1 passenger', style: totalStyle),
                if (!widget.alwaysExpanded)
                  Icon(_isOpen ? Icons.expand_less : Icons.expand_more, size: 20),
                const Spacer(),
                Text(Pricing.format(Pricing.total(price)), style: totalStyle),
              ],
            ),
          ),
        ),
        if (_isOpen) ...[
          const Divider(),
          _breakdownRow(label: const Text("Driver's price"), amount: Pricing.format(Pricing.subtotal(price))),
          const SizedBox(height: 8),
          _breakdownRow(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Service fee'),
                IconButton(
                  padding: const EdgeInsets.only(left: 8),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.info_outline, size: 18),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Service fee'),
                      content: const Text(
                          'This fee helps support TagAlong’s platform and covers a broad range of operating costs including app maintenance and support.'),
                      actions: <Widget>[
                        TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            amount: Pricing.format(Pricing.serviceFee(price)),
          ),
          const SizedBox(height: 8),
          _breakdownRow(label: const Text('Taxes'), amount: Pricing.format(Pricing.tax(price))),
        ],
      ],
    );
  }

  Widget _breakdownRow({required Widget label, required String amount}) {
    return Row(
      children: [
        label,
        const Spacer(),
        Text(amount),
      ],
    );
  }
}
