import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
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

class RideStripePaymentScreen extends StatefulWidget {
  const RideStripePaymentScreen({Key? key, required this.ride}) : super(key: key);

  final RideModel ride;
  @override
  State<RideStripePaymentScreen> createState() => _RideStripePaymentScreenState();
}

class _RideStripePaymentScreenState extends State<RideStripePaymentScreen> {
  final controller = CardFormEditController();
  late TagAlongUser tagAlongUser;

  bool _saveCard = true;
  @override
  void initState() {
    controller.addListener(update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    final _tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    tagAlongUser = _tagAlongUserViewModel.tagAlongUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CardFormField(
                controller: controller,
                countryCode: 'US',
                style: CardFormStyle(
                  borderColor: Colors.black,
                  textColor: Colors.black,
                  fontSize: 24,
                  placeholderColor: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Save Card'),
                value: _saveCard,
                onChanged: (value) {
                  setState(() {
                    _saveCard = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 12),
              LoadingButton(
                onPressed: controller.details.complete == true ? _handlePayPress : null,
                text: 'Confirm my ride · ${Pricing.format(Pricing.total(widget.ride.price))}',
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Save Card :',
                  style: _themeData.textTheme.titleMedium,
                ),
              ),
              FutureBuilder<StripePaymentMethodResponse>(
                future: StripeCustomerRepository.instance.getPaymentMethod(tagAlongUser.stripeCustomerId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!.data.data;

                    return Column(
                      children: List.generate(data.length, (index) {
                        return InkWell(
                          onTap: () {
                            _handlePayPress(paymentMethodId: data[index].id);
                          },
                          child: CreditCardWidget(
                            cardNumber: data[index].card.last4,
                            expiryDate: '${data[index].card.expMonth}/${data[index].card.expYear}',
                            cardHolderName: '',
                            cvvCode: '',
                            showBackView: false,
                            isHolderNameVisible: false,
                            isSwipeGestureEnabled: false,
                            isChipVisible: false,
                            onCreditCardWidgetChange: (creditCardBrand) {}, //true when you want to show cvv(back) view
                          ),
                        );
                      }),
                    );
                  }

                  if (snapshot.hasError) {
                    logger.log.fine(snapshot.error);
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    child: const CircularProgressIndicator(),
                  );
                },
              )
            ],
          ),
        ),
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
          customerId: _saveCard ? customerId : null, //only pass customer Id in case of save card
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

        final bookedRide =
            await _bookRide(widget.ride, paymentIntentResult.data.id, paymentIntentResult.data.charges.data[0].id);

        await _showBookingConfirmed(bookedRide);
        return;
      }

      if (paymentIntentResult.data.status == 'requires_action') {
        // 4. if payment requires action calling handleNextAction
        final paymentIntent = await Stripe.instance.handleNextAction(paymentIntentResult.data.clientSecret);

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

          final bookedRide =
              await _bookRide(widget.ride, paymentIntentResult.data.id, paymentIntentResult.data.charges.data[0].id);

          await _showBookingConfirmed(bookedRide);
        }
      }
    } catch (error, stacktrace) {
      logger.log.fine(stacktrace);
      await _showBookingFailed();
      // rethrow;
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
            'You’ve successfully booked a ride with ${ride.getFirstNameAndInitial()} to $dropoff, departing on $date at ${ride.departureTimeOfDay}.'),
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
        content: const Text(
            'Please reach out to our support team at support@tagalongrides.com for assistance.'),
      ),
    );
  }

  /// Records the booking and returns the ride as it now stands, with the seat
  /// taken and the rider attached.
  Future<RideModel> _bookRide(RideModel ride, String paymentIntentId, String chargeId) async {
    // Create Ride booking entry
    final rideBooking = await RideBookingRepository.instance.bookRide(RideBookingModel(
      rideId: ride.rideId,
      userId: tagAlongUser.id,
      creatadAt: DateTime.now(),
      chargeId: chargeId,
      paymentIntentId: paymentIntentId,
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
