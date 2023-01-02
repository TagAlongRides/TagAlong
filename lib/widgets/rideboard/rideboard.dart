import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_repo/ride_repo.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/rideboard/rideboard_card.dart';

class RideBoard extends StatefulWidget {
  const RideBoard({Key? key}) : super(key: key);

  @override
  State<RideBoard> createState() => _RideBoardState();
}

class _RideBoardState extends State<RideBoard> {
  bool _bannerDismissed = false;
  @override
  Widget build(BuildContext context) {
    logger.log.fine('RideBoardList Build');
    final userViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    // Listening to RideBoardViewModel so when user "updates filters", we
    // rebuild this RideBoard Widget, hence re-querying data with filters
    var rideBoardViewModel = Provider.of<RideBoardViewModel>(context, listen: true);

    // The "RefreshIndicator" will allow us to refresh the Rideboard to get the
    // most up-to-date Rides based on set filters within RideBoardViewModel
    // RideRepository.instance.getMyOfferedRides('qPL64AIflCfwXKMQ5OV5zDvnY4I2').then((value) {
    //   log(value.toString());
    // });
    return RefreshIndicator(
      onRefresh: rideBoardViewModel.getRidesBasedOnFilters,
      child: FutureBuilder<void>(
        future: rideBoardViewModel.getRidesBasedOnFilters(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // Case 1: Future has NOT completed yet and asynchronous
          // computation has begun
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Case 2: Future has completed and is no longer computing
          else if (snapshot.connectionState == ConnectionState.done) {
            // Case 2a: Error
            if (snapshot.hasError) {
              return Text('Error has occur ${snapshot.error.toString()}');
            }
            // Case 2b: Data has returned - cannot occur because Future
            // does not return data, but updates ViewModel
            else if (snapshot.hasData) {
              logger.log.fine('RideBoard - Data has return but how!');
              return getListViewOfRides(rideBoardViewModel.querySnapshot!);
            }
            // Case 2c: Future has completed, and ViewModel has hopefully
            // been updated with updated data
            else {
              return Column(
                children: [
                  if (!userViewModel.isEmailVerified() && !_bannerDismissed)
                    Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.up,
                      onDismissed: (_) {
                        setState(() {
                          _bannerDismissed = true;
                        });
                      },
                      child: MaterialBanner(
                        content: const Text('Heads up! You have to verify your email address before booking a ride'),
                        backgroundColor: TagAlongTheme.colorError,
                        actions: [
                          TextButton(
                            onPressed: () {
                              userViewModel.sendEmailVerificationToUser();
                              setState(() {
                                _bannerDismissed = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Verification email sent to ${userViewModel.tagAlongUser?.emailAddress}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
                            child: const Text('RESEND'),
                          )
                        ],
                      ),
                    ),
                  Expanded(child: getListViewOfRides(rideBoardViewModel.querySnapshot!)),
                ],
              );
            }
          } else {
            return const Text('Something went wrong');
          }
        },
      ),
    );
  }

  /// returns a ListView of ALL rides ordered by the `departure_date_time`.
  ///
  /// [querySnapshot] is the QuerySnapshot from RideBoardViewModel, most likely
  /// calling [getRidesBasedOnFilters] method.
  ListView getListViewOfRides(QuerySnapshot<Object?> querySnapshot) {
    return ListView.builder(
        itemCount: querySnapshot.docs.length,
        itemBuilder: (context, i) {
          RideModel ride = RideModel.fromJson(querySnapshot.docs[i].data() as Map<String, dynamic>);
          return RideBoardCard(ride: ride);
        });
  }
}
