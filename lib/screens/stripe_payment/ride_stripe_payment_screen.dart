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
                            onCreditCardWidgetChange: (CreditCardBrand) {}, //true when you want to show cvv(back) view
                          ),
                        );
                      }),
                    );
                  }

                  if (snapshot.hasError) {
                    print(snapshot.error);
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
      final paymentIntentResult = await StripeConnectRepository.instance.createDestinationPayemntIntent(
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
        // Payment succedeed

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
          // 5. Call API to confirm intent
          // Stripe.instance.confirmPayment(
          //   paymentIntentResult.data.clientSecret!,
          //   PaymentMethodData(
          //     billingDetails: billingDetails,
          //   ),
          // );
          // await confirmIntent(paymentIntent.id);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Require Confirmation !: The payment was successfully!, but require confirmation')));
        } else {
          // Payment succedeed

          await _bookRide(widget.ride, paymentIntentResult.data.id, paymentIntentResult.data.charges.data[0].id);

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Success!: The payment was confirmed successfully!')));
          Navigator.of(context).pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false);
        }
      }
    } catch (error, stacktrace) {
      print(stacktrace);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment Failed, Please try again later.')));
      rethrow;
    }
  }

  Future _bookRide(RideModel ride, String paymentIntentId, String chargeId) async {
    /// Create Ride booking entry
    final rideBooking = await RideBookingRepository.instance.bookRide(RideBookingModel(
      rideId: ride.rideId,
      userId: tagAlongUser.id,
      creatadAt: DateTime.now(),
      chargeId: chargeId,
      paymentIntentId: paymentIntentId,
    ));

    /// Update Ride doc with ride booking id
    ride.rideBookingIds.add(rideBooking.rideBookingId);
    await RideRepository.instance.updateRide(ride);
  }
}
