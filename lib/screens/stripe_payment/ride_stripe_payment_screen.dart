import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

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
                text: 'Pay',
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Save Card :',
                  style: _themeData.textTheme.subtitle1,
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
      String amount = (widget.ride.price * 1.20 * 100).toStringAsFixed(0); //Charges in cent
      String applicationFee = (widget.ride.price * .20 * 100).toStringAsFixed(0); //Charges in cent

      final billingDetails = BillingDetails(
        email: email,
      ); // mocked data for tests

      final currentBookings =
          await RideBookingRepository.instance.getRideBookingForRideId(widget.ride.rideId, isCanceled: false);

      // Do not allow user to book ride if all seats are already taken
      if (currentBookings.length >= widget.ride.noPassengers) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Sorry! This ride has no more seats remaining.')));
        logger.log.fine('Book ride failed - no seats remaining');
        Navigator.of(context).pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false);
        throw Exception('Book ride failed, no seats remaining');
      }

      // 2. Create payment method
      if (paymentMethodId == null) {
        final paymentMethod = await Stripe.instance.createPaymentMethod(PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: billingDetails,
            ),
            options: const PaymentMethodOptions(setupFutureUsage: PaymentIntentsFutureUsage.OffSession)));
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

        await _bookRide(widget.ride, paymentIntentResult.data.id, paymentIntentResult.data.charges.data[0].id);

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Success!: The payment was confirmed successfully!')));
        Navigator.of(context).pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false);
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

          await _bookRide(widget.ride, paymentIntentResult.data.id, paymentIntentResult.data.charges.data[0].id);

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Success!: The payment was confirmed successfully!')));
          Navigator.of(context).pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false);
        }
      }
    } catch (error, stacktrace) {
      logger.log.fine(stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed, please try again.')));
      // rethrow;
    }
  }

  Future _bookRide(RideModel ride, String paymentIntentId, String chargeId) async {
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
  }
}
