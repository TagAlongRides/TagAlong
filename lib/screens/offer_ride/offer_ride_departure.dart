import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
        backgroundColor: Colors.transparent,
        iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetDepartureDateTime();
              vm.resetDepartureTimeOfDay();
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
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
          ],
        ),
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
          const SizedBox(height: 40),
          Container(
            height: 20,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 24),
            child: Text(
              'Date',
              style: theme.TagAlongTheme.lightTextTheme.subtitle1!.copyWith(
                color: theme.TagAlongTheme.primarySwatch.shade900,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            height: 80,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: offerRideViewModel.departureDateTime != null
                        ? RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.headline4,
                              children: [
                                TextSpan(
                                  text: DateFormat('EEE').format(
                                      offerRideViewModel.departureDateTime!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black38,
                                  ),
                                ),
                                TextSpan(
                                  text: DateFormat(' MMMM dd').format(
                                      offerRideViewModel.departureDateTime!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Text("Choose a date",
                            style: theme.TagAlongTheme.lightTextTheme.headline4!
                                .copyWith(
                              color: Colors.black45,
                              fontWeight: FontWeight.normal,
                            )),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: OutlinedButton(
                    style:
                        theme.TagAlongTheme.outlinedButtonTheme.style!.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                          theme.TagAlongTheme.secondarySwatch.shade200),
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          side: BorderSide(width: 0, color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: 30,
                      color: theme.TagAlongTheme.primarySwatch.shade900,
                    ),
                    onPressed: () async {
                      DateTime chosenDate =
                          offerRideViewModel.departureDateTime ??
                              DateTime.now();
                      final DateTime? newDate = await showDatePicker(
                        context: context,
                        initialDate: chosenDate,
                        firstDate: chosenDate,
                        lastDate: DateTime.now().add(const Duration(days: 180)),
                        helpText: 'DEPARTURE DATE',
                      );
                      offerRideViewModel.updateDepartureDateTime(newDate);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            height: 20,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 24),
            child: Text(
              'Time',
              style: theme.TagAlongTheme.lightTextTheme.subtitle1!.copyWith(
                color: theme.TagAlongTheme.primarySwatch.shade900,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            height: 80,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: Container(
                    child: offerRideViewModel.departureTimeOfDay != null
                        ? RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.headline4,
                              children: [
                                TextSpan(
                                  text: offerRideViewModel.departureTimeOfDay,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text("Choose a time",
                            style: theme.TagAlongTheme.lightTextTheme.headline4!
                                .copyWith(
                              color: Colors.black,
                            )),
                  ),
                ),
                Container(
                  // padding: EdgeInsets.symmetric(horizontal: 15),
                  margin: EdgeInsets.only(right: 15),
                  child: OutlinedButton(
                    style:
                        theme.TagAlongTheme.outlinedButtonTheme.style!.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                          theme.TagAlongTheme.secondarySwatch.shade200),
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.schedule_outlined,
                      color: theme.TagAlongTheme.primarySwatch.shade900,
                      size: 30,
                    ),
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
                  ),
                ),
              ],
            ),
          ),
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
