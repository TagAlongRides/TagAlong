import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/widgets/question_widget.dart';
import 'package:tagalong/util/log.dart' as logger;


class OfferRidePickup extends StatefulWidget {
  const OfferRidePickup({Key? key}) : super(key: key);

  @override
  State<OfferRidePickup> createState() => _OfferRidePickupState();
}

class _OfferRidePickupState extends State<OfferRidePickup> {
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    var offerRideViewModel = Provider.of<OfferRideViewModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              offerRideViewModel.resetPickupLocation();
              Navigator.of(context).pop();
            }
        ),
        title: const Text('Offer a Ride'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Question
              const QuestionWidget(
                  question: 'Pickup location?'
              ),

              // 2. TextFormField OR DropdownButtonFormField
              if (offerRideViewModel.toCampus)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    initialValue: offerRideViewModel.pickupLocation,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.edit_location_outlined),
                      labelText: 'Pickup Location',
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please enter a valid address';
                      }
                      offerRideViewModel.updatePickupLocation(text);
                      return null;
                    },
                  ),
                )
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
                      offerRideViewModel.updatePickupLocation(pickUpLocation!);
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
            logger.log.fine('OfferRidePickUp - $offerRideViewModel');
            Navigator.pushNamed(context, '/offer_ride_dropoff');
          }
        },
      ),
    );
  }
}
