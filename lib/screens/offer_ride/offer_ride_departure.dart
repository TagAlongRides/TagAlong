import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_trip_details.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';

class OfferRideDeparture extends StatefulWidget {
  const OfferRideDeparture({Key? key}) : super(key: key);
  static const routeName = '/offer_ride_departure';

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
              // Back Button ; Pop out to previous Screen
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetDepartureDateTime();
              vm.resetDepartureTimeOfDay();
              Navigator.of(context).pop();
            }),
        title: _getProgressBar(),
      ),
      body: Consumer<OfferRideViewModel>(builder: (context, offerRideViewModel, child) {
        return Column(children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.headlineMedium,
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
            margin: const EdgeInsets.only(left: 16, bottom: 10),
            child: Text(
              'Date',
              style: theme.TagAlongTheme.lightTextTheme.titleMedium!.copyWith(
                color: theme.TagAlongTheme.primarySwatch.shade900,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            // height: 100,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              style: theme.TagAlongTheme.outlinedButtonTheme.style!.copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              onPressed: () async {
                DateTime chosenDate = offerRideViewModel.departureDateTime ?? DateTime.now();
                final DateTime? newDate = await showDatePicker(
                  context: context,
                  initialDate: chosenDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                  helpText: 'DEPARTURE DATE',
                );
                offerRideViewModel.updateDepartureDateTime(newDate);
              },
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      child: offerRideViewModel.departureDateTime != null
                          ? FittedBox(
                              fit: BoxFit.contain,
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.headlineMedium,
                                  children: [
                                    TextSpan(
                                      text: DateFormat('EEEE').format(offerRideViewModel.departureDateTime!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: DateFormat(' MMMM dd').format(offerRideViewModel.departureDateTime!),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Text("Choose a date",
                              style: theme.TagAlongTheme.lightTextTheme.titleLarge!.copyWith(
                                color: Colors.black45,
                                fontWeight: FontWeight.normal,
                              )),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.calendar_today,
                      size: 30,
                      color: theme.TagAlongTheme.primarySwatch.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            height: 20,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, bottom: 10),
            child: Text(
              'Time',
              style: theme.TagAlongTheme.lightTextTheme.titleMedium!.copyWith(
                color: theme.TagAlongTheme.primarySwatch.shade900,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          Container(
            // height: 65,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: OutlinedButton(
              style: theme.TagAlongTheme.outlinedButtonTheme.style!.copyWith(
                backgroundColor: MaterialStateProperty.all(
                    // theme.TagAlongTheme.secondarySwatch.shade200
                    Colors.white),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              onPressed: () async {
                late TimeOfDay chosenTime;

                // User HAS chosen a TimeOfDay to leave - convert String to TimeOfDay
                if (offerRideViewModel.departureTimeOfDay != null) {
                  chosenTime = RideModel.timeOfDayFromString(offerRideViewModel.departureTimeOfDay!);
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
                offerRideViewModel.updateDepartureTimeOfDay(newTime?.format(context));
              },
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      child: offerRideViewModel.departureTimeOfDay != null
                          ? RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                style: Theme.of(context).textTheme.headlineMedium,
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
                              style: theme.TagAlongTheme.lightTextTheme.titleLarge!.copyWith(
                                color: Colors.black45,
                              )),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.schedule_outlined,
                      color: theme.TagAlongTheme.primarySwatch.shade900,
                      size: 30,
                    ),
                  ),
                ],
              ),
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
                    content: const Text('Please make sure to input a valid departure date & time'),
                    actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
            return;
          }
          logger.log.fine('Leaving OfferRideDeparture');
          Navigator.pushNamed(context, OfferRideTripDetails.routeName);
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
      Icon(Icons.circle_outlined),
      SizedBox(width: 10),
      Icon(Icons.circle_outlined),
    ]);
  }
}
