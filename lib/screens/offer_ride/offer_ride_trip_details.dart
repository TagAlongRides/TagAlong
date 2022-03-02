import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRideTripDetails extends StatelessWidget {
  const OfferRideTripDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetNoPassengers();
              vm.resetNoBags();
              Navigator.of(context).pop();
            }
        ),
        title: const Text('Offer a Ride'),
      ),
      body: Consumer<OfferRideViewModel>(
        builder: (context, offerRideViewModel, child) {
          return SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Question
                  const QuestionWidget(
                      question: 'How many passengers?'
                  ),
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => offerRideViewModel.decrementNoPassengers()
                            ),
                            Text(
                                '${offerRideViewModel.noPassengers}',
                                style: Theme.of(context).textTheme.headline1
                            ),
                            IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => offerRideViewModel.incrementNoPassengers()
                            ),
                          ]
                      )
                  ),
                  const QuestionWidget(
                      question: 'How many bags per passenger?'
                  ),
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => offerRideViewModel.decrementNoBags()
                            ),
                            Text(
                                '${offerRideViewModel.noBags}',
                                style: Theme.of(context).textTheme.headline1
                            ),
                            IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => offerRideViewModel.incrementNoBags()
                            ),
                          ]
                      )
                  ),
                ]
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          Navigator.pushNamed(context, '/offer_ride_price_prefs');
        },
      ),
    );
  }
}
