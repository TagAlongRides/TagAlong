import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

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
    var buttonWidth = MediaQuery.of(context).size.width * .35;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetPrice();
              vm.resetVaccinationCard();
              Navigator.of(context).pop();
            }),
        title: Row(
          children: const [
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle),
          ],
        ),
      ),
      body: SingleChildScrollView(child: Consumer<OfferRideViewModel>(
          builder: (context, offerRideViewModel, child) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 1. Question
          Padding(
            padding: const EdgeInsets.all(24),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headline4,
                children: const [
                  TextSpan(
                    text: 'What is the ',
                  ),
                  TextSpan(
                    text: 'price per person?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),

          Padding(
              padding: const EdgeInsets.all(12),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => offerRideViewModel.decrementPrice()),
                Text('${offerRideViewModel.price}',
                    style: Theme.of(context).textTheme.headline2),
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => offerRideViewModel.incrementPrice()),
              ])),

          Padding(
            padding: const EdgeInsets.all(24),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headline4,
                text: 'Any notes for the passenger?',
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                maxLength: 280,
                controller: notesController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Are you on the talkative or quiet side?'
                      ' Are there some car rules? Any specific music you like listening to?'
                      ' If there\'s anything you\'d like people to know, this is the place to put it.',
                  hintStyle:
                      theme.TagAlongTheme.lightTextTheme.bodyText1!.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.TagAlongTheme.colorMediumEmphasis,
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 6,
              )),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
            child: Row(children: [
              Checkbox(
                value: offerRideViewModel.vaccinationCard,
                onChanged: (bool? value) {
                  offerRideViewModel.updateVaccinationCard();
                },
              ),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.caption,
                    children: const [
                      TextSpan(
                        text:
                            'If you require proof of vaccination or wearing a mask, check the box.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ' This requirement will be shown to passengers viewing your ride, and you reserve the right to refuse a ride to anyone who refuses to comply with your car rules.',
                      )
                    ],
                  ),
                ),
              )
            ]),
          ),
          Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: buttonWidth,
                      height: 50,
                      child: ElevatedButton(
                        child: const Text('Cancel'),
                        onPressed: () async {
                          return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Cancel Ride'),
                                content: const Text(
                                    'Are you sure you want to cancel your ride posting?'
                                    '\nThis will reset your progress and take you back to the Rideboard.'),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Back')),
                                  TextButton(
                                    onPressed: () {
                                      offerRideViewModel.resetAll();
                                      logger.log.fine(
                                          'Canceling OfferRidePricePrefs');
                                      Navigator.popUntil(context,
                                          ModalRoute.withName('/ride_board'));
                                    },
                                    child: const Text('Cancel'),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: buttonWidth,
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
                                    child: const Text('Back'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      offerRideViewModel
                                          .updateNotes(notesController.text);
                                      await offerRideViewModel.createNewRide();
                                      logger.log
                                          .fine('Posting OfferRidePricePrefs');
                                      Navigator.popUntil(context,
                                          ModalRoute.withName('/ride_board'));
                                    },
                                    child: const Text('Post'),
                                  )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ]))
        ]);
      })),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    notesController.dispose();
    super.dispose();
  }
}
