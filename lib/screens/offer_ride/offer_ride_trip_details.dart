import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_price_prefs.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

class OfferRideTripDetails extends StatelessWidget {
  const OfferRideTripDetails({Key? key}) : super(key: key);
  static const routeName = '/offer_ride_trip_details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetNoPassengers();
              vm.resetNoBags();
              Navigator.of(context).pop();
            }),
        title: _getProgressBar(),
      ),
      body: Consumer<OfferRideViewModel>(builder: (context, offerRideViewModel, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Question
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: const [
                      TextSpan(
                        text: 'How many passengers',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' will you take?',
                      )
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.caretUp,
                        size: 36,
                        color: theme.TagAlongTheme.primarySwatch.shade400,
                      ),
                      onPressed: () => offerRideViewModel.incrementNoPassengers()),
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: theme.TagAlongTheme.colorHighEmphasis,
                        ),
                      ),
                    ),
                    child: Text(
                      '${offerRideViewModel.noPassengers}',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.caretDown,
                        size: 36,
                        color: theme.TagAlongTheme.primarySwatch.shade400,
                      ),
                      onPressed: () => offerRideViewModel.decrementNoPassengers()),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: const [
                      TextSpan(
                        text: 'How many bags',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' can each person bring?',
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.caretUp,
                          size: 36,
                          color: theme.TagAlongTheme.primarySwatch.shade400,
                        ),
                        onPressed: () => offerRideViewModel.incrementNoBags()),
                    Container(
                      width: 100,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                      ),
                      child: Text('${offerRideViewModel.noBags}', style: Theme.of(context).textTheme.displayMedium),
                    ),
                    IconButton(
                        icon: Icon(
                          FontAwesomeIcons.caretDown,
                          size: 36,
                          color: theme.TagAlongTheme.primarySwatch.shade400,
                        ),
                        onPressed: () => offerRideViewModel.decrementNoBags()),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          logger.log.fine('Leaving OfferRideTripDetails');
          Navigator.pushNamed(context, OfferRidePricePrefs.routeName);
        },
      ),
    );
  }

  Widget _getProgressBar() {
    return Row(children: const [
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
      Icon(Icons.circle_outlined),
    ]);
  }
}
