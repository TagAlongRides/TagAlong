import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/screens/stripe_payment/ride_stripe_payment_screen.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/pricing.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// The money side of a ride: the passenger's price breakdown or receipt, or
/// the driver's (estimated) earnings, plus the cancel button in My Rides.
///
/// Booking a seat is not in here; see [RideReserveBar].
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
    Provider.of<RideDetailsViewModel>(context, listen: false).instantiateRide(ride: ride);

    // A passenger only has a receipt once they have booked, which is when this
    // is shown from My Rides.
    final header = isDriver ? (isInFuture ? 'Estimated earnings' : 'Earnings') : (isMyRides ? 'Receipt' : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TagAlongCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ...[
                Text(header, style: TagAlongText.titleMedium),
                const SizedBox(height: TagAlongSpace.s3),
              ],
              if (isDriver) ..._driverEarnings(),

              // Passengers see the full price breakdown. Before booking it is
              // collapsed behind an expandable total; on a receipt it is
              // always open.
              if (!isDriver) _PriceBreakdown(ride: ride, alwaysExpanded: isMyRides),
            ],
          ),
        ),
        if (isMyRides && isInFuture && !isCancelled)
          Padding(
            padding: const EdgeInsets.only(top: TagAlongSpace.s4),
            child: LoadingButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TagAlongColors.surface,
                foregroundColor: TagAlongColors.errorInk,
                side: const BorderSide(color: TagAlongColors.error, width: 1.5),
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
              text: isDriver ? 'Cancel ride & notify riders' : 'Cancel ride & give up my seat',
            ),
          ),
      ],
    );
  }

  /// The driver's side of the ledger — headcount and per-passenger take.
  List<Widget> _driverEarnings() {
    //TODO - Create a more robust way to manage the number of currently booked passengers
    final booked = ride.noPassengers - ride.remainingSeats;
    return [
      TagAlongReceiptRow(label: 'Passengers', value: '$booked'),
      const SizedBox(height: 10),
      TagAlongReceiptRow(label: 'Price per passenger', value: Pricing.format(ride.price.toDouble())),
      if (isMyRides) ...[
        const Padding(padding: EdgeInsets.symmetric(vertical: TagAlongSpace.s3), child: Divider(height: 1)),
        TagAlongReceiptRow(
          label: 'Total earnings',
          value: Pricing.format((booked * ride.price).toDouble()),
          emphasis: true,
          valueColor: TagAlongColors.successInk,
        ),
      ],
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

/// Sticky bar on a ride's detail page: the total for one seat and the
/// "Reserve seat" button, which runs the pre-booking checks before opening
/// the payment screen.
class RideReserveBar extends StatelessWidget {
  const RideReserveBar({Key? key, required this.ride}) : super(key: key);

  final RideModel ride;

  void _bounce(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.of(context).pushNamed(RideBoardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return TagAlongStickyBar(
      child: Consumer<TagAlongUserViewModel>(
        builder: (context, user, child) {
          final isVerified = user.isEmailVerified();
          return Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Pricing.format(Pricing.total(ride.price)), style: TagAlongText.price),
                    Text('1 seat · incl. fees',
                        style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: isVerified ? () => _reserve(context, user) : () => _askToVerify(context, user),
                style: isVerified
                    ? null
                    : ElevatedButton.styleFrom(
                        backgroundColor: TagAlongColors.border,
                        foregroundColor: TagAlongColors.textSecondary,
                      ),
                child: Text(isVerified ? 'Reserve seat' : 'Verify email to book'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _reserve(BuildContext context, TagAlongUserViewModel user) {
    if (user.tagAlongUser!.id == ride.driverId) {
      _bounce(context, 'Cannot reserve a seat because you are the driver of this ride');
    } else if (ride.riderIds.contains(user.tagAlongUser!.id)) {
      _bounce(context, 'You have already reserved a seat on this ride');
    } else if (ride.remainingSeats <= 0) {
      _bounce(context, 'Sorry! This ride has no more seats remaining.');
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RideStripePaymentScreen(ride: ride)));
    }
  }

  void _askToVerify(BuildContext context, TagAlongUserViewModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Please verify email'),
          content: const Text(
              'Heads up! In order to book a ride you’ll need to confirm your email. Would you like us to resend your confirmation email?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No, thanks.'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Yes, please!'),
              onPressed: () {
                user.sendEmailVerificationToUser();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Verification email sent to ${user.tagAlongUser?.emailAddress}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

/// "Total for 1 seat" with an expandable breakdown of the driver's price, the
/// service fee, and taxes (Milestone 3, §2.1.3).
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

  void _explainServiceFee() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service fee'),
        content: const Text(
            'This fee helps support TagAlong’s platform and covers a broad range of operating costs including app maintenance and support.'),
        actions: <Widget>[
          TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.ride.price;
    final total = Row(
      children: [
        Text('Total for 1 seat', style: TagAlongText.titleSmall),
        if (!widget.alwaysExpanded)
          Icon(_isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 20, color: TagAlongColors.textTertiary),
        const Spacer(),
        Text(Pricing.format(Pricing.total(price)), style: TagAlongText.price),
      ],
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isOpen) ...[
            TagAlongReceiptRow(label: "Driver's price", value: Pricing.format(Pricing.subtotal(price))),
            const SizedBox(height: 10),
            TagAlongReceiptRow(
              label: 'Service fee',
              value: Pricing.format(Pricing.serviceFee(price)),
              onInfo: _explainServiceFee,
            ),
            const SizedBox(height: 10),
            TagAlongReceiptRow(label: 'Taxes', value: Pricing.format(Pricing.tax(price))),
            const Padding(padding: EdgeInsets.symmetric(vertical: TagAlongSpace.s3), child: Divider(height: 1)),
          ],
          widget.alwaysExpanded
              ? total
              : InkWell(
                  borderRadius: TagAlongRadius.smAll,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Semantics(
                    expanded: _isOpen,
                    hint: _isOpen ? 'Hide price breakdown' : 'Show price breakdown',
                    child: total,
                  ),
                ),
        ],
      ),
    );
  }
}
