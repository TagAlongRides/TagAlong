import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/screens/my_ride/my_ride_detail_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/util/pricing.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

class RideStripePaymentScreen extends StatefulWidget {
  const RideStripePaymentScreen({Key? key, required this.ride}) : super(key: key);

  final RideModel ride;
  @override
  State<RideStripePaymentScreen> createState() => _RideStripePaymentScreenState();
}

class _RideStripePaymentScreenState extends State<RideStripePaymentScreen> {
  final controller = CardFormEditController();
  late TagAlongUser tagAlongUser;
  late final Future<StripePaymentMethodResponse> _savedCards;

  bool _saveCard = true;

  /// The saved card to charge, or null to charge the card typed into the form.
  String? _selectedMethodId;

  /// Whether we have picked a default (the first saved card) yet.
  bool _defaultChosen = false;

  @override
  void initState() {
    controller.addListener(update);
    super.initState();
    tagAlongUser = Provider.of<TagAlongUserViewModel>(context, listen: false).tagAlongUser!;
    _savedCards = StripeCustomerRepository.instance.getMyPaymentMethods();
    _savedCards.then((response) {
      final cards = response.data.data;
      if (!mounted || _defaultChosen) return;
      setState(() {
        _defaultChosen = true;
        // The default card if the user has one, else their first card.
        final defaultId = response.data.defaultPaymentMethod;
        if (cards.any((card) => card.id == defaultId)) {
          _selectedMethodId = defaultId;
        } else if (cards.isNotEmpty) {
          _selectedMethodId = cards.first.id;
        }
      });
    }).catchError((Object error) {
      logger.log.fine(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final total = Pricing.format(Pricing.total(ride.price));
    final pickup = ride.pickupLocation.label ?? ride.pickupLocation.city;
    final dropoff = ride.dropoffLocation.label ?? ride.dropoffLocation.city;
    final usingNewCard = _selectedMethodId == null;

    final Future<void> Function()? pay = usingNewCard
        ? (controller.details.complete == true ? () => _handlePayPress() : null)
        : () => _handlePayPress(paymentMethodId: _selectedMethodId);

    return Scaffold(
      appBar: const TagAlongTopBar(title: 'Confirm & pay'),
      bottomNavigationBar: TagAlongStickyBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingButton(onPressed: pay, text: 'Confirm my ride · $total'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 14, color: TagAlongColors.textTertiary),
                const SizedBox(width: 6),
                Text('Payments are processed securely by Stripe',
                    style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s2, TagAlongSpace.gutter, TagAlongSpace.s6),
        children: [
          // Trip summary
          Container(
            padding: const EdgeInsets.all(TagAlongSpace.s4),
            decoration: BoxDecoration(
              color: TagAlongColors.directionSoft(ride.toCampus),
              borderRadius: TagAlongRadius.lgAll,
            ),
            child: Row(
              children: [
                TagAlongDateBlock(date: ride.departureDateTime, color: TagAlongColors.direction(ride.toCampus)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$pickup → $dropoff', style: TagAlongText.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('EEE').format(ride.departureDateTime)} ${ride.departureTimeLabel} · '
                        'Driver: ${ride.getFirstNameAndInitial()}',
                        style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TagAlongSpace.s5),

          // Pay with
          const TagAlongSectionHeader(title: 'Pay with'),
          const SizedBox(height: TagAlongSpace.s3),
          FutureBuilder<StripePaymentMethodResponse>(
            future: _savedCards,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(TagAlongSpace.s4),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final cards = snapshot.data?.data.data ?? const [];
              return Column(
                children: [
                  for (final card in cards) ...[
                    _SavedCardTile(
                      brand: card.card.brand,
                      last4: card.card.last4,
                      expiry: '${card.card.expMonth.toString().padLeft(2, '0')}/${card.card.expYear % 100}',
                      selected: _selectedMethodId == card.id,
                      onTap: () => setState(() => _selectedMethodId = card.id),
                    ),
                    const SizedBox(height: TagAlongSpace.s3),
                  ],
                  _NewCardTile(
                    selected: usingNewCard,
                    onTap: () => setState(() => _selectedMethodId = null),
                  ),
                ],
              );
            },
          ),
          if (usingNewCard) ...[
            const SizedBox(height: TagAlongSpace.s3),
            CardFormField(
              controller: controller,
              countryCode: 'US',
              style: CardFormStyle(
                backgroundColor: TagAlongColors.surface,
                borderColor: TagAlongColors.border,
                borderWidth: 2,
                borderRadius: TagAlongRadius.md.round(),
                cursorColor: TagAlongColors.brand,
                textColor: TagAlongColors.textPrimary,
                textErrorColor: TagAlongColors.errorInk,
                placeholderColor: TagAlongColors.textTertiary,
                fontSize: 16,
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text('Save this card for next time', style: TagAlongText.bodyMedium),
              value: _saveCard,
              onChanged: (value) => setState(() => _saveCard = value ?? false),
            ),
          ],
          const SizedBox(height: TagAlongSpace.s4),

          // Summary
          TagAlongCard(
            child: Column(
              children: [
                TagAlongReceiptRow(label: "Driver's price", value: Pricing.format(Pricing.subtotal(ride.price))),
                const SizedBox(height: 10),
                TagAlongReceiptRow(label: 'Service fee', value: Pricing.format(Pricing.serviceFee(ride.price))),
                const SizedBox(height: 10),
                TagAlongReceiptRow(label: 'Taxes', value: Pricing.format(Pricing.tax(ride.price))),
                const Padding(padding: EdgeInsets.symmetric(vertical: TagAlongSpace.s3), child: Divider(height: 1)),
                TagAlongReceiptRow(label: 'Total', value: total, emphasis: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(update);
    controller.dispose();
    super.dispose();
  }

  void update() => setState(() {});

  Future<void> _handlePayPress({String? paymentMethodId}) async {
    // if (!controller.details.complete) {
    //   return;
    // }

    // A saved card belongs to the Stripe customer, so it can only be charged
    // with the customer attached, whatever the "save card" box says.
    final usingSavedCard = paymentMethodId != null;

    try {
      // 1. Gather customer billing information (ex. email)
      String email = tagAlongUser.emailAddress;
      String customerId = tagAlongUser.stripeCustomerId;
      String driverAccountID = widget.ride.stripeAccountId;
      // The passenger is charged the driver's price plus the service fee and
      // taxes; the driver receives their price and TagAlong keeps the rest
      // (Milestone 4, §1.1.1).
      String amount = Pricing.totalInCents(widget.ride.price); //Charges in cent
      String applicationFee = Pricing.applicationFeeInCents(widget.ride.price); //Charges in cent

      final billingDetails = BillingDetails(
        email: email,
      ); // mocked data for tests

      final currentBookings =
          await RideBookingRepository.instance.getRideBookingForRideId(widget.ride.rideId, isCanceled: false);

      // Do not allow user to book ride if all seats are already taken. This is
      // an expected outcome, not a payment failure, so bail out before we
      // charge anything rather than falling through to the error dialog.
      if (currentBookings.length >= widget.ride.noPassengers) {
        logger.log.fine('Book ride failed - no seats remaining');
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Sorry! This ride has no more seats remaining.')));
        Navigator.of(context).pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false);
        return;
      }

      // 2. Create payment method
      if (paymentMethodId == null) {
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
          ),
          options: const PaymentMethodOptions(setupFutureUsage: PaymentIntentsFutureUsage.OffSession),
        );
        paymentMethodId = paymentMethod.id;
      }

      // 3. call API to create PaymentIntent
      final paymentIntentResult = await StripeConnectRepository.instance.createDestinationPaymentIntent(
        StripePaymentIntentRequest(
          email: email,
          customerId:
              _saveCard || usingSavedCard ? customerId : null, //only pass customer Id when saving or reusing a card
          amount: amount,
          paymentMethodId: paymentMethodId,
          returnUrl: stripeConnectReturnUrl,
          applicationFee: applicationFee,
          destination: driverAccountID,
          transferGroup: widget.ride.rideId,
        ),
      );

      if (paymentIntentResult.data.status == 'succeeded') {
        // Payment succeeded

        final bookedRide = await _bookRide(widget.ride, paymentIntentResult.data);

        await _showBookingConfirmed(bookedRide);
        return;
      }

      if (paymentIntentResult.data.status == 'requires_action') {
        // 4. if payment requires action calling handleNextAction
        final clientSecret = paymentIntentResult.data.clientSecret;
        if (clientSecret == null) {
          // Stripe asked for further action but gave us nothing to act on.
          logger.log.warning('Payment intent ${paymentIntentResult.data.id} requires action with no client secret');
          await _showBookingFailed();
          return;
        }
        final paymentIntent = await Stripe.instance.handleNextAction(clientSecret);

        if (paymentIntent.status == PaymentIntentsStatus.RequiresConfirmation) {
          log('Stripe payment intent ${paymentIntent.id} requires confirmation. Recommended action is: ${paymentIntent.nextAction}');
          // 5. Call API to confirm intent
          // Stripe.instance.confirmPayment(
          //   paymentIntentResult.data.clientSecret!,
          //   PaymentMethodData(
          //     billingDetails: billingDetails,
          //   ),
          // );
          // await confirmIntent(paymentIntent.id);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Your payment requires confirmation before it can be processed. The recommended next step is: ${paymentIntent.nextAction}. Contact TagAlong support for assistance.'),
            duration: const Duration(seconds: 15),
          ));
        } else {
          // Payment succedeed

          final bookedRide = await _bookRide(widget.ride, paymentIntentResult.data);

          await _showBookingConfirmed(bookedRide);
        }
      }
    } catch (error, stacktrace) {
      // The passenger only ever sees "contact support", so this log is the one
      // record of what actually went wrong. It used to log the stack trace
      // alone, without the error, at fine level - which the default INFO
      // threshold then discarded, leaving a failed booking with nothing at all
      // to diagnose.
      logger.log.severe('Ride booking failed: $error', error, stacktrace);
      await _showBookingFailed();
    }
  }

  /// Tells the passenger the booking worked, then drops them on the Upcoming
  /// Ride page in My Rides (Milestone 3, §2.1.6 and Milestone 4, §2.2).
  Future<void> _showBookingConfirmed(RideModel ride) async {
    if (!mounted) return;

    final dropoff = ride.dropoffLocation.label ?? ride.dropoffLocation.city;
    final date = DateFormat('EEEE, MMMM d').format(ride.departureDateTime);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hooray!'),
        content: Text(
            'You’ve successfully booked a ride with ${ride.getFirstNameAndInitial()} to $dropoff, departing on $date at ${ride.departureTimeLabel}.'),
        actions: <Widget>[
          TextButton(child: const Text('View my ride'), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );

    if (!mounted) return;
    // Clear the booking flow, then open the ride so backing out lands on the
    // Ride Board rather than the card form.
    Navigator.of(context).pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false);
    Navigator.of(context).pushNamed(MyRideDetailScreen.routeName, arguments: ride);
  }

  /// Milestone 3, §2.1.7 — a dismissible pop-up pointing the user at support.
  Future<void> _showBookingFailed() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('Oops, that didn’t work!')),
            IconButton(
              icon: const Icon(Icons.close),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: const Text('Please reach out to our support team at support@tagalongrides.com for assistance.'),
      ),
    );
  }

  /// Records the booking and returns the ride as it now stands, with the seat
  /// taken and the rider attached.
  Future<RideModel> _bookRide(RideModel ride, StripePaymentIntent intent) async {
    final chargeId = intent.latestChargeId;
    if (chargeId == null) {
      // The passenger has already paid at this point, so the booking has to be
      // recorded regardless - losing it would be far worse than storing it
      // without this id. A dispute can still be matched to the booking by its
      // payment intent, which is what the dispute handler falls back to.
      logger.log.warning('Payment intent ${intent.id} settled without a charge id');
    }

    // Create Ride booking entry
    final rideBooking = await RideBookingRepository.instance.bookRide(RideBookingModel(
      rideId: ride.rideId,
      userId: tagAlongUser.id,
      creatadAt: DateTime.now(),
      chargeId: chargeId ?? '',
      paymentIntentId: intent.id,
    ));

    // Pull data from Firebase again in case of recent updates
    final rideFromRepo = await RideRepository.instance.getRideById(ride.rideId);
    // Update Ride doc with ride booking id and rider id
    rideFromRepo.rideBookingIds.add(rideBooking.rideBookingId);
    rideFromRepo.riderIds.add(tagAlongUser.id);
    // Remove 1 remaining seat from the ride
    rideFromRepo.remainingSeats--;
    await RideRepository.instance.updateRide(rideFromRepo);
    return rideFromRepo;
  }
}

/// A saved card as a selectable tile with a radio.
class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.selected,
    required this.onTap,
  });

  final String brand;
  final String last4;
  final String expiry;
  final bool selected;
  final VoidCallback onTap;

  String get _brandName => switch (brand.toLowerCase()) {
        'visa' => 'Visa',
        'mastercard' => 'Mastercard',
        'amex' => 'Amex',
        'discover' => 'Discover',
        _ => brand.isEmpty ? 'Card' : brand[0].toUpperCase() + brand.substring(1),
      };

  String get _badge => switch (brand.toLowerCase()) {
        'visa' => 'VISA',
        'mastercard' => 'MC',
        'amex' => 'AMEX',
        _ => _brandName.substring(0, _brandName.length.clamp(0, 4)).toUpperCase(),
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: TagAlongCard(
        shadow: false,
        onTap: onTap,
        border: Border.all(color: selected ? TagAlongColors.brand : TagAlongColors.border, width: selected ? 2 : 1.5),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: brand.toLowerCase() == 'visa' ? TagAlongColors.brandSoft : TagAlongColors.toCampus,
                borderRadius: TagAlongRadius.smAll,
              ),
              child: Text(_badge, style: TagAlongText.labelMedium),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_brandName •••• $last4', style: TagAlongText.titleSmall),
                  Text('Expires $expiry', style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                ],
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

/// Dashed "Add a new card" tile; selecting it shows the card form.
class _NewCardTile extends StatelessWidget {
  const _NewCardTile({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: CustomPaint(
        foregroundPainter: selected ? null : const _DashedBorderPainter(),
        child: TagAlongCard(
          shadow: false,
          color: selected ? TagAlongColors.surface : Colors.transparent,
          border: selected ? Border.all(color: TagAlongColors.brand, width: 2) : null,
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: TagAlongColors.subtle, shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, size: 18, color: TagAlongColors.textBrand),
              ),
              const SizedBox(width: TagAlongSpace.s3),
              Expanded(
                child: Text('Add a new card', style: TagAlongText.labelLarge.copyWith(color: TagAlongColors.textBrand)),
              ),
              if (selected) const _Radio(selected: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? TagAlongColors.brand : null,
        border: selected ? null : Border.all(color: TagAlongColors.borderStrong, width: 2),
      ),
      child: selected ? const Icon(Icons.check_rounded, size: 16, color: TagAlongColors.textOnInverse) : null,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TagAlongColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.75),
      const Radius.circular(TagAlongRadius.lg),
    );
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
