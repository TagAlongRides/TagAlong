import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/util/university_locations.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

class OfferRidePickup extends StatefulWidget {
  const OfferRidePickup({Key? key}) : super(key: key);

  @override
  State<OfferRidePickup> createState() => _OfferRidePickupState();
}

class _OfferRidePickupState extends State<OfferRidePickup> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetPickupLocation();
              vm.resetCityAndZip();
              Navigator.of(context).pop();
            }),
        title: Row(
          children: const [
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
            SizedBox(width: 10),
            Icon(Icons.circle_outlined),
          ],
        ),
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
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headline4,
                          children: const [
                            TextSpan(
                              text: 'Where will you ',
                            ),
                            TextSpan(
                              text: 'pick up',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: ' passengers?',
                            )
                          ],
                        ),
                      ),
                    ),

                    // 2. TextFormField OR DropdownButtonFormField
                    if (offerRideViewModel.toCampus)
                      Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: TextFormField(
                            initialValue: offerRideViewModel.pickupLocation,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.edit_location_outlined),
                              labelText: 'Address*',
                            ),
                            validator: (pickup) {
                              if (pickup == null || pickup.isEmpty) {
                                return 'Address is required';
                              }
                              offerRideViewModel.updatePickupLocation(pickup);
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
                              labelText: 'Pickup Location',
                            ),
                            value: offerRideViewModel.pickupLocation,
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Please choose a valid pickup location';
                              }
                              return null;
                            },
                            onChanged: (String? pickUpLocation) {
                              offerRideViewModel
                                  .updatePickupLocation(pickUpLocation!);
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
            logger.log.fine('Leaving OfferRidePickUp');
            Navigator.pushNamed(context, '/offer_ride_dropoff');
          }
        },
      ),
    );
  }
}
