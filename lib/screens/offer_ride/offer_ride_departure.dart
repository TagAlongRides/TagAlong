import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

class OfferRideDeparture extends StatefulWidget {
  const OfferRideDeparture({Key? key}) : super(key: key);

  @override
  _OfferRideDepartureState createState() => _OfferRideDepartureState();
}

class _OfferRideDepartureState extends State<OfferRideDeparture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetDepartureDateTime();
              vm.resetDepartureTimeOfDay();
              Navigator.of(context).pop();
            }),
        title: const Text('Offer a Ride'),
      ),
      body: Consumer<OfferRideViewModel>(
          builder: (context, offerRideViewModel, child) {
        return Column(children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headline4,
                  children: const [
                    TextSpan(
                      text: 'When will you depart',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' from the pick-up location?',
                    )
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: theme.TagAlongTheme.elevatedButtonTheme.style,
            onPressed: () async {
              DateTime chosenDate =
                  offerRideViewModel.departureDateTime ?? DateTime.now();
              final DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: chosenDate,
                firstDate: chosenDate,
                lastDate: DateTime.now().add(const Duration(days: 180)),
                helpText: 'DEPARTURE DATE',
              );
              offerRideViewModel.updateDepartureDateTime(newDate);
            },
            child: const Text('Select departure date'),
          ),
          const SizedBox(height: 8),
          if (offerRideViewModel.departureDateTime != null)
            Text(
              'Leaving on ${offerRideViewModel.departureDateTime!.toIso8601String().split('T').first}',
            ),
          const SizedBox(height: 8),
          if (offerRideViewModel.departureDateTime != null)
            ElevatedButton(
              onPressed: () async {
                late TimeOfDay chosenTime;

                // User HAS chosen a TimeOfDay to leave - convert String to TimeOfDay
                if (offerRideViewModel.departureTimeOfDay != null) {
                  chosenTime = Ride.timeOfDayFromString(
                      offerRideViewModel.departureTimeOfDay!);
                }
                // User HAS NOT chosen a TimeOfDay to leave - default to current time
                else {
                  chosenTime = const TimeOfDay(hour: 12, minute: 00);
                }

                final TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: chosenTime,
                  initialEntryMode: TimePickerEntryMode.input,
                  helpText: 'DEPARTURE TIME',
                );
                offerRideViewModel
                    .updateDepartureTimeOfDay(newTime?.format(context));
              },
              child: const Text('Select departure time'),
            )
          else
            const ElevatedButton(
              onPressed: null,
              child: Text('Select departure time'),
            )
        ]);
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () async {
          var vm = Provider.of<OfferRideViewModel>(context, listen: false);
          if (vm.departureDateTime == null || vm.departureTimeOfDay == null) {
            await showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                        title: const Text('Not Completed'),
                        content: const Text(
                            'Please make sure to input a valid departure date & time'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'))
                        ]));
            return;
          }
          logger.log.fine('Leaving OfferRideDeparture');
          Navigator.pushNamed(context, '/offer_ride_trip_details');
        },
      ),
    );
  }
}
