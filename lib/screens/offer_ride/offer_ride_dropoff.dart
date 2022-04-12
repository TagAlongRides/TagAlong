import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/offer_ride/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:us_states/us_states.dart';

import '../../util/university_locations.dart';

class OfferRideDropoff extends StatefulWidget {
  const OfferRideDropoff({Key? key}) : super(key: key);

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
              var vm = Provider.of<OfferRideViewModel>(context, listen: false);
              vm.resetCityAndZip();
              vm.resetDropoffLocation();
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
                            initialValue: offerRideViewModel.dropoffLocation,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.edit_location_outlined),
                              labelText: 'Street Address',
                              labelStyle: theme
                                  .TagAlongTheme.lightTextTheme.bodyText2!
                                  .copyWith(
                                fontStyle: FontStyle.normal,
                                color: theme.TagAlongTheme.colorHighEmphasis,
                              ),
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
                            decoration: InputDecoration(
                              icon: const Icon(Icons.location_city),
                              labelText: 'City',
                              labelStyle: theme
                                  .TagAlongTheme.lightTextTheme.bodyText2!
                                  .copyWith(
                                fontStyle: FontStyle.normal,
                                color: theme.TagAlongTheme.colorHighEmphasis,
                              ),
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
                          child: DropdownButtonFormField<String>(
                            items: _statesList,
                            value: offerRideViewModel.locationState,
                            onChanged: (state) {
                              offerRideViewModel.locationState = state;
                            },
                            decoration: InputDecoration(
                              icon: const Icon(FontAwesomeIcons.flagUsa),
                              labelText: 'State',
                              labelStyle: theme
                                  .TagAlongTheme.lightTextTheme.bodyText2!
                                  .copyWith(
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
                            initialValue: offerRideViewModel.locationZip,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.code),
                              labelText: 'Zip Code',
                              labelStyle: theme
                                  .TagAlongTheme.lightTextTheme.bodyText2!
                                  .copyWith(
                                fontStyle: FontStyle.normal,
                                color: theme.TagAlongTheme.colorHighEmphasis,
                              ),
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
                            decoration: InputDecoration(
                              icon: const Icon(Icons.edit_location_outlined),
                              labelText: 'Drop off Location',
                              labelStyle: theme
                                  .TagAlongTheme.lightTextTheme.bodyText2!
                                  .copyWith(
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
