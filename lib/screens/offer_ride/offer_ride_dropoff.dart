import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_departure.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:us_states/us_states.dart';

import '../../util/university_locations.dart';

class OfferRideDropoff extends StatefulWidget {
  const OfferRideDropoff({Key? key}) : super(key: key);
  static const routeName = '/offer_ride_dropoff';

  @override
  _OfferRideDropoffState createState() => _OfferRideDropoffState();
}

class _OfferRideDropoffState extends State<OfferRideDropoff> {
  List<DropdownMenuItem<String>> get _statesList {
    var stateAbbreviations = USStates.getAllAbbreviations();
    return stateAbbreviations.map((state) {
      return DropdownMenuItem(
        child: Text(state),
        value: state,
      );
    }).toList();
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
              vm.resetCityAndZip();
              vm.resetDropoffLocation();
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
                      style: Theme.of(context).textTheme.headline4,
                      children: const [
                        TextSpan(
                          text: 'Where will you ',
                        ),
                        TextSpan(
                          text: 'drop off',
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
                if (!offerRideViewModel.toCampus)
                  Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: TextFormField(
                        keyboardType: TextInputType.streetAddress,
                        textCapitalization: TextCapitalization.words,
                        initialValue: offerRideViewModel.dropoffLocation,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.edit_location_outlined),
                          labelText: 'Street Address',
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyText2!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        validator: (dropoff) {
                          if (dropoff == null || dropoff.isEmpty) {
                            return 'Please enter a street address';
                          }
                          offerRideViewModel.updateDropoffLocation(dropoff);
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
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyText2!.copyWith(
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
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyText2!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        validator: (state) {
                          if (state == null) {
                            return 'State is required';
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
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyText2!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        validator: (zip) {
                          if (zip == null || zip.isEmpty) {
                            return 'Zip is required';
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
                          labelText: 'Drop off Location',
                          labelStyle: theme.TagAlongTheme.lightTextTheme.bodyText2!.copyWith(
                            fontStyle: FontStyle.normal,
                            color: theme.TagAlongTheme.colorHighEmphasis,
                          ),
                        ),
                        value: offerRideViewModel.dropoffLocation,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Please choose a valid drop off location';
                          }
                          return null;
                        },
                        onChanged: (String? dropoffLocation) {
                          offerRideViewModel.updateDropoffLocation(dropoffLocation!);
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
            logger.log.fine('Leaving OfferRideDropOff');
            Navigator.pushNamed(context, OfferRideDeparture.routeName);
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
      Icon(Icons.circle),
      SizedBox(width: 10),
      Icon(Icons.circle_outlined),
      SizedBox(width: 10),
      Icon(Icons.circle_outlined),
      SizedBox(width: 10),
      Icon(Icons.circle_outlined),
    ]);
  }
}
