import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/data/models/ride.dart';
import 'package:tagalong/viewmodels/offer_ride_view_model.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/util/log.dart' as logger;

class RideBoard extends StatelessWidget {

  const RideBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.log.fine('RideBoardList Build');
    var rideBoardViewModel = Provider.of<RideBoardViewModel>(context, listen:true);

    // Listening to OfferRideViewModel for the case when a Driver posts a ride -
    // The rideboard should refresh to show that ride.
    var offerRideViewModel = Provider.of<OfferRideViewModel>(context, listen:true);

    // Compute "getAllRidesData()" by default on regular build, showing
    // a [CircularProgressIndicator] while user waits for completion.
    return FutureBuilder<QuerySnapshot<Object?>>(
      // future: rideBoardViewModel.getAllRidesData(),
      future: rideBoardViewModel.getRidesBasedOnFilters(
          filters: rideBoardViewModel.filters
      ),
      builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
            // Case 1: Future has NOT completed
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // Case 2: Future has completed
            else if (snapshot.connectionState == ConnectionState.done) {
              // Case 2a: Error
              if (snapshot.hasError) {
                return const Text('Error has occur');
              }
              // Case 2b: Data exists
              else if (snapshot.hasData) {
                return getListViewOfRides(snapshot.data!);
              }
              else {
                return const Text('adfasdf');
              }
            }
            else {
              return const Text('adfasdf');
            }
          },
    );
  }

  /// returns a ListView of ALL rides ordered by the `departure_date_time`.
  ListView getListViewOfRides(QuerySnapshot<Object?> querySnapshot) {
    return ListView.builder(
      itemCount: querySnapshot.docs.length,
      itemBuilder: (context, i) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.directions_car_rounded),
            title: Text(querySnapshot.docs[i]['ride_id']),
            trailing: Text('\$${querySnapshot.docs[i]["price"]}'),
            onTap: () {
              Ride ride = Ride.fromJson(querySnapshot.docs[i].data() as Map<String, dynamic>);
              logger.log.fine(ride.toString());
            },
            onLongPress: () {

            }
          ),
        );
      }
    );
  }
}
