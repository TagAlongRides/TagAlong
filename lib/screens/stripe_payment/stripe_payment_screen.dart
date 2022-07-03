import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

class StripePaymentScreen extends StatefulWidget {
  const StripePaymentScreen({Key? key, required this.ride}) : super(key: key);

  final Ride ride;
  @override
  State<StripePaymentScreen> createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final controller = CardFormEditController();
  late TagAlongUser tagAlongUser;
  @override
  void initState() {
    controller.addListener(update);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    final _tagAlongUserViewModel =
        Provider.of<TagAlongUserViewModel>(context, listen: false);
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
              LoadingButton(
                onPressed: controller.details.complete == true
                    ? _handlePayPress
                    : null,
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
                future: StripeCustomerRepository.instance
                    .getPaymentMethod(tagAlongUser.stripeCustomerId),
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
                            expiryDate:
                                '${data[index].card.expMonth}/${data[index].card.expYear}',
                            cardHolderName: '',
                            cvvCode: '',
                            showBackView: false,
                            isHolderNameVisible: false,
                            isSwipeGestureEnabled: false,
                            isChipVisible: false,
                            onCreditCardWidgetChange:
                                (CreditCardBrand) {}, //true when you want to show cvv(back) view
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
      String driverCustomerID = widget.ride.stripeAccountId;
      String amount =
          (widget.ride.price * 1.20 * 100).toStringAsFixed(0); //Charges in cent
      String applicationFee =
          (widget.ride.price * .20 * 100).toStringAsFixed(0); //Charges in cent

      final billingDetails = BillingDetails(
        email: email,
      ); // mocked data for tests

      // 2. Create payment method
      if (paymentMethodId == null) {
        final paymentMethod = await Stripe.instance.createPaymentMethod(
            PaymentMethodParams.card(
                paymentMethodData: PaymentMethodData(
                  billingDetails: billingDetails,
                ),
                options: const PaymentMethodOptions(
                    setupFutureUsage: PaymentIntentsFutureUsage.OffSession)));
        paymentMethodId = paymentMethod.id;
      }

      // 3. call API to create PaymentIntent
      final paymentIntentResult =
          await StripeConnectRepository.instance.createPayemntIntent(
        StripePaymentIntentRequest(
            email: email,
            customerId: customerId,
            amount: amount,
            paymentMethodId: paymentMethodId,
            returnUrl: stripeConnectReturnUrl,
            applicationFee: applicationFee,
            destination: driverCustomerID),
      );

      if (paymentIntentResult.data.clientSecret != null &&
          paymentIntentResult.data.status == 'succeeded') {
        // Payment succedeed

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Success!: The payment was confirmed successfully!')));
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/ride_board', (route) => false);
        return;
      }

      if (paymentIntentResult.data.clientSecret != null &&
          paymentIntentResult.data.status == 'requires_action') {
        // 4. if payment requires action calling handleNextAction
        final paymentIntent = await Stripe.instance
            .handleNextAction(paymentIntentResult.data.clientSecret!);

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
              content: Text(
                  'Require Confirmation !: The payment was successfully!, but require confirmation')));
        } else {
          // Payment succedeed

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content:
                  Text('Success!: The payment was confirmed successfully!')));
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/ride_board', (route) => false);
        }
      }
    } catch (error, stacktrace) {
      print(stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Payment Failed, Please try again later.')));
      rethrow;
    }
  }
}
