import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_dropoff.dart';
import 'package:tagalong/util/university_locations.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:us_states/us_states.dart';

class OfferRidePickup extends StatefulWidget {
  const OfferRidePickup({Key? key}) : super(key: key);
  static const routeName = '/offer_ride_pickup';

  @override
  State<OfferRidePickup> createState() => _OfferRidePickupState();
}

class _OfferRidePickupState extends State<OfferRidePickup> {
  List<DropdownMenuItem<String>> get _statesList {
    var stateAbbreviations = USStates.getAllAbbreviations();
    return stateAbbreviations.map((state) {
      return DropdownMenuItem(
        child: Text(state),
        value: state,
      );
    }).toList();
    // return states;
  }

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
              // Back Button ; Pop out to previous Screen
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetPickupLocation();
              vm.resetCityAndZip();
              Navigator.of(context).pop();
            }),
        title: _getProgressBar(),
      ),
      body: Form(
          key: _formKey,
          child: Consumer<OfferRideViewModel>(builder: (context, offerRideViewModel, child) {
            return SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 1. Question
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineMedium,
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
                        keyboardType: TextInputType.streetAddress,
                        textCapitalization: TextCapitalization.words,
                        initialValue: offerRideViewModel.pickupLocation,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.edit_location_outlined),
                          labelText: 'Street Address',
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        validator: (pickup) {
                          if (pickup == null || pickup.isEmpty) {
                            return 'Please enter a street address';
                          }
                          offerRideViewModel.updatePickupLocation(pickup);
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        initialValue: offerRideViewModel.locationCity,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.location_city),
                          labelText: 'City',
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        validator: (city) {
                          if (city == null || city.isEmpty) {
                            return 'Please enter a city';
                          }
                          offerRideViewModel.updateLocationCity(city);
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: DropdownButtonFormField<String>(
                        items: _statesList,
                        value: offerRideViewModel.locationState,
                        onChanged: (state) {
                          offerRideViewModel.locationState = state;
                        },
                        decoration: InputDecoration(
                          icon: const Icon(FontAwesomeIcons.flagUsa),
                          labelText: 'State',
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        validator: (state) {
                          if (state == null) {
                            return 'Please choose a state';
                          }
                          offerRideViewModel.updateLocationState(state);
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: offerRideViewModel.locationZip,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.code),
                          labelText: 'Zip Code',
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        validator: (zip) {
                          if (zip == null || zip.isEmpty) {
                            return 'Please enter a zip code';
                          } else if (int.tryParse(zip) == null) {
                            return 'Please enter a numeric zip code';
                          } else if (zip.length != 5) {
                            return 'Please enter a valid 5 digit U.S zip code';
                          }
                          offerRideViewModel.updateLocationZip(zip);
                          return null;
                        },
                      ),
                    ),
                  ])
                else
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          icon: const Icon(Icons.edit_location_outlined),
                          labelText: 'Pickup Location',
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        value: offerRideViewModel.pickupLocation,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Please choose a valid pickup location';
                          }
                          return null;
                        },
                        onChanged: (String? pickUpLocation) {
                          offerRideViewModel.updatePickupLocation(pickUpLocation!);
                        },
                        items: VirginiaTechLocation.locationNames.map<DropdownMenuItem<String>>((String location) {
                          return DropdownMenuItem<String>(child: Text(location), value: location);
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
            Navigator.pushNamed(context, OfferRideDropoff.routeName);
          }
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
