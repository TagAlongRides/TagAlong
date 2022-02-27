import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRideCampus extends StatelessWidget {
  const OfferRideCampus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var offerRideViewModel = Provider.of<OfferRideViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            offerRideViewModel.resetCampusChoice();
            Navigator.of(context).pop();
          }
        ),
        title: const Text('Offer a Ride'),
      ),
      body: Column(
        children: [
          // 1. Question
          const Flexible(
            flex: 1,
            child: QuestionWidget(
              question: 'Where are you heading?'
            )
          ),
          Flexible(
            flex: 5,
            child: Column(
              children: [
                ChoiceChip(
                  selected: offerRideViewModel.toCampus,
                  label: const SizedBox(
                    width: 120,
                    child: Text('To Campus')
                  ),
                  onSelected: (bool selected) {
                    offerRideViewModel.toCampusChoice();
                  },
                ),
                ChoiceChip(
                  selected: !offerRideViewModel.toCampus,
                  label: const SizedBox(
                    width: 120,
                    child: Text('From Campus'),
                  ),
                  onSelected: (bool selected) {
                    offerRideViewModel.fromCampusChoice();
                  },
                )
              ],
            )
          )
        ]
      ),
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          logger.log.fine('OfferRideCampus - $offerRideViewModel');
          Navigator.pushNamed(context, '/offer_ride_pickup');
        },
      ),
    );
  }
}
