import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRideDeparture extends StatefulWidget {
  const OfferRideDeparture({Key? key}) : super(key: key);

  @override
  _OfferRideDepartureState createState() => _OfferRideDepartureState();
}

class _OfferRideDepartureState extends State<OfferRideDeparture> {

  @override
  Widget build(BuildContext context) {
    var offerRideViewModel = Provider.of<OfferRideViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              offerRideViewModel.resetDepartureDateTime();
              offerRideViewModel.resetDepartureTimeOfDay();
              Navigator.of(context).pop();
            }
        ),
        title: const Text('Offer a Ride'),
      ),
      body: Column(
        children: [
          const QuestionWidget(
              question: 'Date & Time of Departure?'
          ),
          ElevatedButton(
            onPressed: () async {
              DateTime chosenDate = offerRideViewModel.departureDateTime ?? DateTime.now();
              final DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: chosenDate,
                firstDate: chosenDate,
                lastDate: DateTime(2022, 12),
                helpText: 'Select a date to leave',
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
                TimeOfDay chosenTime = offerRideViewModel.departureTimeOfDay ?? TimeOfDay.now();
                final TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: chosenTime
                );
                offerRideViewModel.updateDepartureTimeOfDay(newTime);
              }
              ,
              child: const Text('Select departure time'),
            )
          else
            const ElevatedButton(
              onPressed: null,
              child: Text('Select departure time'),
            )
        ]
      ),
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () async {
          logger.log.fine('OfferRideDeparture - $offerRideViewModel');
          if (offerRideViewModel.departureDateTime == null || offerRideViewModel.departureTimeOfDay == null) {
            await showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Not Completed'),
                content: const Text('Please make sure to input a valid departure date & time'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK')
                  )
                ]
              )
            );
            return;
          }
          Navigator.pushNamed(context, '/offer_ride_trip_details');
        },
      ),
    );
  }
}
