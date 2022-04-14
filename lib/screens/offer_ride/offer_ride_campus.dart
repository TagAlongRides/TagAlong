import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

class OfferRideCampus extends StatelessWidget {
  const OfferRideCampus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: theme.TagAlongTheme.colorHighEmphasis,
            onPressed: () {
              // Back Button ; Pop out to previous Screen
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetCampusChoice();
              Navigator.of(context).pop();
            }),
        title: _getProgressBar(),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 1. Question
        // const QuestionWidget(question: 'Where are your travel plans?'),
        Padding(
          padding: const EdgeInsets.all(24),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headline4,
              text: 'What are your travel plans?',
            ),
          ),
        ),
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

  Widget _getProgressBar() {
    return Row(
        children: const [
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
        ]);
  }
}
