import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/screens/stripe_payment/ride_stripe_payment_screen.dart';
import 'package:tagalong/viewmodels/ride_details_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

class RideDetailPricing extends StatelessWidget {
  const RideDetailPricing({
    Key? key,
    required this.context,
    required this.ride,
    this.isDriver = false,
  }) : super(key: key);

  final BuildContext context;
  final RideModel ride;
  // TODO - Implement UI changes based on these vars
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    var rideDetailsViewModel = Provider.of<RideDetailsViewModel>(context, listen: false);
    rideDetailsViewModel.instantiateRide(ride: ride);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Subtotal
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Subtotal'), Text('\$${ride.price}')]),
          const SizedBox(height: 16),

          // Service Fee
          Row(children: [
            const Text('Service Fee'),
            const SizedBox(width: 16),
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
          ]),
          // "Continue" Button
          const SizedBox(height: 16),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                        // Navigator.of(context).pushNamed('/stripe-payment');
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return RideStripePaymentScreen(ride: ride);
                          },
                        ));
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
          )
        ],
      ),
    );
  }
}
