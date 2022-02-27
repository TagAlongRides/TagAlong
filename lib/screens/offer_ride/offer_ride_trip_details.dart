import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRideTripDetails extends StatelessWidget {
  const OfferRideTripDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var offerRideViewModel = Provider.of<OfferRideViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              offerRideViewModel.resetNoPassengers();
              offerRideViewModel.resetNoBags();
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
                  question: 'How many passengers?'
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  icon: Icon(Icons.people),
                  labelText: 'Passenger Count',
                ),
                value: offerRideViewModel.noPassengers,
                onChanged: (int? noPassengers) {
                  offerRideViewModel.updateNoPassengers(noPassengers!);
                },
                items: offerRideViewModel.PASSENGERS.map((passengerOption) =>
                  DropdownMenuItem<int>(
                    child: Text('$passengerOption'),
                    value: passengerOption
                  )
                ).toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: QuestionWidget(
                  question: 'How many bags per passenger?'
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  icon: Icon(Icons.backpack),
                  labelText: 'Bag Count',
                ),
                value: offerRideViewModel.noBags,
                onChanged: (int? noBags) {
                  offerRideViewModel.updateNoBags(noBags!);
                },
                items: offerRideViewModel.BAGS.map((bagOption) =>
                    DropdownMenuItem<int>(
                        child: Text('$bagOption'),
                        value: bagOption
                    )
                ).toList(),
              ),
            ),
          ]
      ),
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          logger.log.fine('OfferRideCampus - $offerRideViewModel');
          Navigator.pushNamed(context, '/offer_ride_price_prefs');
        },
      ),
    );
  }
}
