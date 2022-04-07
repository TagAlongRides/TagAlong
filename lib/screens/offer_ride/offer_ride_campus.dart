import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRideCampus extends StatelessWidget {
  const OfferRideCampus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetCampusChoice();
              Navigator.of(context).pop();
            }),
        title: const Text('Offer a Ride'),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 1. Question
        const QuestionWidget(question: 'Where are you heading?'),
        Center(child: Consumer<OfferRideViewModel>(
            builder: (context, offerRideViewModel, child) {
          return Column(
            children: [
              ChoiceChip(
                selected: offerRideViewModel.toCampus,
                label: Container(
                  width: 120,
                  alignment: Alignment.center,
                  child: const Text('To Campus'),
                ),
                onSelected: (bool selected) {
                  offerRideViewModel.toCampusChoice();
                },
              ),
              ChoiceChip(
                selected: !offerRideViewModel.toCampus,
                label: Container(
                  width: 120,
                  alignment: Alignment.center,
                  child: const Text('From Campus'),
                ),
                onSelected: (bool selected) {
                  offerRideViewModel.fromCampusChoice();
                },
              )
            ],
          );
        }))
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          logger.log.fine('Leaving OfferRideCampus');
          Navigator.pushNamed(context, '/offer_ride_pickup');
        },
      ),
    );
  }
}
