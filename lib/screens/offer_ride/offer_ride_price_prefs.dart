import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRidePricePrefs extends StatefulWidget {
  const OfferRidePricePrefs({Key? key}) : super(key: key);

  @override
  State<OfferRidePricePrefs> createState() => _OfferRidePricePrefsState();
}

class _OfferRidePricePrefsState extends State<OfferRidePricePrefs> {
  TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var vm = Provider.of<OfferRideViewModel>(context, listen: false);
    print('HERE: ${vm.runtimeType}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetPrice();
              vm.resetVaccinationCard();
              Navigator.of(context).pop();
            }
        ),
        title: const Text('Offer a Ride'),
      ),
      body: SingleChildScrollView(
        child: Consumer<OfferRideViewModel>(
          builder: (context, offerRideViewModel, child) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Question
                  const QuestionWidget(
                      question: 'Price per person?'
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
                  ),
                  const QuestionWidget(
                      question: 'Require vaccination card?'
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                        children: [
                          Checkbox(
                            value: offerRideViewModel.vaccinationCard,
                            onChanged: (bool? value) {
                              offerRideViewModel.updateVaccinationCard();
                            },
                          ),
                          const Flexible(
                              child: Text('Require proof of vaccination card on arrival.'))
                        ]
                    ),
                  ),
                  const QuestionWidget(
                      question: 'Any notes?'
                  ),
                  Padding(
                      padding: const EdgeInsets.all(24),
                      child: TextField(
                        maxLength: 280,
                        controller: notesController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Are you on the talkative or quiet side?'
                                ' Are there some car rules? Any specific music you like listening to?'
                                ' If there\'s anything you\'d like people to know, this is the place to put it.'
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: ElevatedButton(
                                  child: const Text('Cancel'),
                                  onPressed: () async {
                                    return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Cancel Ride'),
                                          content: const Text('Are you sure you want to cancel your ride posting?'
                                              '\nThis will reset your progress and take you back to the Rideboard.'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Back')
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                offerRideViewModel.resetAll();
                                                logger.log.fine('Canceling OfferRidePricePrefs');
                                                Navigator.popUntil(context, ModalRoute.withName('/ride_board'));
                                              },
                                              child: const Text('Cancel')
                                            )
                                          ]
                                        );
                                      }
                                    );
                                  }
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              height: 50,
                              child: ElevatedButton(
                                  child: const Text('Post Ride'),
                                  onPressed: () async {
                                    return showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                            title: const Text('Post Ride'),
                                            content: const Text(
                                                'Are you sure you want to post your ride?'
                                                    '\nThis ride will available on the Rideboard as soon as you post!'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Back')
                                              ),
                                              TextButton(
                                                  onPressed: () async {
                                                    offerRideViewModel.updateNotes(notesController.text);
                                                    await offerRideViewModel.createNewRide();
                                                    logger.log.fine('Posting OfferRidePricePrefs');
                                                    Navigator.popUntil(context, ModalRoute.withName('/ride_board'));
                                                  },
                                                  child: const Text('Post')
                                              )
                                            ]
                                        );
                                      }
                                    );
                                  }
                              ),
                            ),
                          ]
                      )
                  )
                ]
            );
          }
        )
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    notesController.dispose();
    super.dispose();
  }
}
