import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;

class OfferRideDropoff extends StatefulWidget {
  const OfferRideDropoff({Key? key}) : super(key: key);

  @override
  _OfferRideDropoffState createState() => _OfferRideDropoffState();
}

class _OfferRideDropoffState extends State<OfferRideDropoff> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var offerRideViewModel = Provider.of<OfferRideViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              offerRideViewModel.resetDropoffLocation();
              Navigator.of(context).pop();
            }
        ),
        title: const Text('Offer a Ride'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
            children: [
              // 1. Question
              const QuestionWidget(
                  question: 'Drop off Location?'
              ),

              // 2. TextFormField OR DropdownButtonFormField
              if (!offerRideViewModel.toCampus)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextFormField(
                    initialValue: offerRideViewModel.dropoffLocation,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.edit_location_outlined),
                      labelText: 'Drop off Location',
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please enter a valid address';
                      }
                      return null;
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(24),
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
                      offerRideViewModel.updateDropoffLocation(dropoffLocation!);
                    },
                    items: const [
                      DropdownMenuItem<String>(
                          child: Text('VT Location 1'),
                          value: 'VT Location 1'
                      ),
                      DropdownMenuItem<String>(
                          child: Text('VT Location 2'),
                          value: 'VT Location 2'
                      ),
                      DropdownMenuItem<String>(
                          child: Text('VT Location 3'),
                          value: 'VT Location 3'
                      )
                    ],
                  ),
                )
            ]
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.arrow_forward_ios),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            logger.log.fine('OfferRideDropoff - $offerRideViewModel');
            Navigator.pushNamed(context, '/offer_ride_departure');
          }
        },
      ),
    );
  }
}
