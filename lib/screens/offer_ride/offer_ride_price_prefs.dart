import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRidePricePrefs extends StatelessWidget {
  const OfferRidePricePrefs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var offerRideViewModel = Provider.of<OfferRideViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              offerRideViewModel.resetPrice();
              Navigator.of(context).pop();
            }
        ),
        title: const Text('Offer a Ride'),
      ),
      body: Column(
          children: [
            // 1. Question
            const Padding(
              padding: EdgeInsets.all(12),
              child: QuestionWidget(
                  question: 'Price per person?'
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => offerRideViewModel.decrementPrice()
                  ),
                  Text(
                  '${offerRideViewModel.price}',
                    style: Theme.of(context).textTheme.headline1
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => offerRideViewModel.incrementPrice()
                  ),
                ]
              )
            )
          ]
      ),
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          logger.log.fine('OfferRideCampus - $offerRideViewModel');
          // Navigator.pushNamed(context, '/offer_ride_pickup');
        },
      ),
    );
  }
}
