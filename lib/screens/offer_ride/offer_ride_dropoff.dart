import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

import '../../util/university_locations.dart';

class OfferRideDropoff extends StatefulWidget {
  const OfferRideDropoff({Key? key}) : super(key: key);

  @override
  _OfferRideDropoffState createState() => _OfferRideDropoffState();
}

class _OfferRideDropoffState extends State<OfferRideDropoff> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetCityAndZip();
              vm.resetDropoffLocation();
              Navigator.of(context).pop();
            }),
        title: const Text('Offer a Ride'),
      ),
      body: Form(
          key: _formKey,
          child: Consumer<OfferRideViewModel>(
              builder: (context, offerRideViewModel, child) {
            return SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Question
                    const QuestionWidget(question: 'Drop off Location?'),

                    // 2. TextFormField OR DropdownButtonFormField
                    if (!offerRideViewModel.toCampus)
                      Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: TextFormField(
                            initialValue: offerRideViewModel.dropoffLocation,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.edit_location_outlined),
                              labelText: 'Address*',
                            ),
                            validator: (dropoff) {
                              if (dropoff == null || dropoff.isEmpty) {
                                return 'Address is required';
                              }
                              offerRideViewModel.updateDropoffLocation(dropoff);
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: TextFormField(
                            initialValue: offerRideViewModel.locationCity,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.location_city),
                              labelText: 'City*',
                            ),
                            validator: (city) {
                              if (city == null || city.isEmpty) {
                                return 'City is required';
                              }
                              offerRideViewModel.updateLocationCity(city);
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: TextFormField(
                            initialValue: offerRideViewModel.locationZip,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.code),
                              labelText: 'Zip Code*',
                            ),
                            validator: (city) {
                              if (city == null || city.isEmpty) {
                                return 'Zip is required';
                              } else if (int.tryParse(city) == null) {
                                return 'Please enter a numeric zip code';
                              }
                              offerRideViewModel.updateLocationZip(city);
                              return null;
                            },
                          ),
                        ),
                      ])
                    else
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.edit_location_outlined),
                              labelText: 'Drop off Location',
                            ),
                            value: offerRideViewModel.dropoffLocation,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Please choose a valid drop off location';
                              }
                              return null;
                            },
                            onChanged: (String? dropoffLocation) {
                              offerRideViewModel
                                  .updateDropoffLocation(dropoffLocation!);
                            },
                            items: VirginiaTechLocation.locationNames
                                .map<DropdownMenuItem<String>>(
                                    (String location) {
                              return DropdownMenuItem<String>(
                                  child: Text(location), value: location);
                            }).toList()),
                      )
                  ]),
            );
          })),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            logger.log.fine('Leaving OfferRideDropOff');
            Navigator.pushNamed(context, '/offer_ride_departure');
          }
        },
      ),
    );
  }
}
