import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/viewmodels/filter_ride_view_model.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/rideboard/rideboard.dart';
import 'package:tagalong/widgets/rideboard/account.dart';
import 'package:tagalong/util/log.dart' as logger;

import '../widgets/rideboard/myrides.dart';

class RideBoardScreen extends StatefulWidget {
  const RideBoardScreen({Key? key}) : super(key: key);

  @override
  _RideBoardScreenState createState() => _RideBoardScreenState();
}

class _RideBoardScreenState extends State<RideBoardScreen>
    with SingleTickerProviderStateMixin {
  // Index for the IndexedStack, representing which Widget to show on the screen
  // based on the BottomNavBar. The initial Widget will be the [RideBoard].
  // Note: The [IndexedStack] maintains state, therefore the build for the
  // IndexedStack children only occurs once, and they all happen at the start.
  // Therefore if you want to [RideBoard, MyRides, Account] UI to show
  // new state, you must rebuild the specific Widget.
  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    logger.log.fine('RideboardScreen Build');

    return Scaffold(
      appBar: _getAppBar(context),
      body: _getBody(context),
      bottomNavigationBar: _getBottomNavBar(context)
    );
  }


  /// UI for the filter Modal Bottom Sheet and its corresponding functionality.
  ///
  /// The UI is built out of 4 main pieces:
  /// 1. The [AppBar]
  /// 2. To/From Campus [ChoiceChips]
  /// 3. Departure Date [TextFormField] + DatePicker
  /// 4. Row of filter buttons
  Widget _getFilterModalBottomSheet(BuildContext context) {
    var filterRideViewModel =
        Provider.of<FilterRideViewModel>(context, listen: false);
    var rideBoardViewModel =
        Provider.of<RideBoardViewModel>(context, listen: false);

    return DraggableScrollableSheet(
        maxChildSize: 0.75,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return ListView(
              controller:
                  scrollController, // Must use controller for draggability
              children: [
                // 1. AppBar
                AppBar(
                  title: const Text('Filter Rides',
                      style: TextStyle(color: Colors.black)),
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.black,
                    // Exit out of the Modal bottom sheet; can also exit by pressing
                    // on the scrim or scrolling down.
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // 2. To/From Campus ChoiceChips
                const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Which way are you heading?')),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Consumer<FilterRideViewModel>(
                        builder: (context, filterRideViewModel, child) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ChoiceChip(
                              label: SizedBox(
                                width: 120,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text('To Campus'),
                                ),
                              ),
                              selected: filterRideViewModel.toCampus,
                              onSelected: (bool selected) =>
                                  filterRideViewModel.toCampusChoice(),
                            ),
                            ChoiceChip(
                                label: SizedBox(
                                  width: 120,
                                  child: Container(
                                    child: const Text('From Campus'),
                                    alignment: Alignment.center,
                                  ),
                                ),
                                selected: !filterRideViewModel.toCampus,
                                onSelected: (bool selected) =>
                                    filterRideViewModel.fromCampusChoice())
                          ]);
                    })),

                const Divider(
                  indent: 16,
                  endIndent: 16,
                ),

                // 3. Departure Date [TextFormField] + DatePicker
                const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('When are you leaving?')),
                Padding(
                  padding: const EdgeInsets.all(8),
                  // "Consumer" listening for FilterRide updates
                  child: Consumer<FilterRideViewModel>(
                      builder: (context, filterRideViewModel, child) {
                    return TextFormField(
                        enableInteractiveSelection: false,
                        readOnly: true,
                        decoration: InputDecoration(
                            hintText:
                                filterRideViewModel.getFormattedDepartureDate(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            suffixIcon: const Icon(Icons.date_range)),

                        // Show the DatePicker
                        onTap: () async {
                          final DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: filterRideViewModel.departureDate ??
                                DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2022, 12),
                            helpText: 'Select a date to leave',
                          );
                          filterRideViewModel.updateDepartureDate(newDate);
                        });
                  }),
                ),

                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Divider(
                    indent: 16,
                    endIndent: 16,
                  ),
                ),

                // 4. Row of filter buttons
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Button to reset ALL filters to default
                      ElevatedButton(
                          onPressed: () => filterRideViewModel.resetAll(),
                          child: const Text('Reset Filters')),

                      // Button to update the user's Ride filters and re-query data,
                      // updating the Rideboard
                      ElevatedButton(
                          onPressed: () {
                            // 1. Pop the BottomModelSheet
                            Navigator.pop(context);

                            // 2. Gathers all the filters and updates the
                            // [RideBoardViewModel]'s filters, which will then notify
                            // [RideBoard] to Re-query and rebuild the ListView
                            Map<String, dynamic> filters = {
                              'to_campus': filterRideViewModel.toCampus,
                              'departure_date_time':
                                  filterRideViewModel.departureDate
                            };
                            rideBoardViewModel.updateFilters(filters);
                          },
                          child: const Text('Filter'))
                    ])
              ]);
        });
  }

  /// Returns [RideBoardScreen] AppBar
  _getAppBar(BuildContext context) {
    // TODO: Take out AuthService - only here for quick debugging
    var authService = Provider.of<AuthService>(context, listen: false);
    return AppBar(
        title: const Text('Ride Board'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          // Filtering Button
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                // Brings up the "BottomModelSheet" for filtering
                return _getFilterModalBottomSheet(context);
              },
            );
          },
        ),
        // TODO: Take out with AuthService
        actions: [
          ElevatedButton(
            onPressed: () {
              authService.signOut();
            },
            child: const Text('Sign Out'),
          )
        ]);
  }

  /// Returns the [RideBoardScreen] body
  Widget _getBody(BuildContext context) {
    return IndexedStack(index: _selectedItem, children: const [
      RideBoard(),
      Text(''), // This should never be shown - represents "Post Ride"
      MyRides(),
      Account()
    ]);
  }


  /// Returns the [RideBoardScreen] BottomNavigationBar
  Widget _getBottomNavBar(BuildContext context) {
    var tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            label: 'Ride Board',
            icon: Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Post Ride',
            icon: Icon(Icons.add),
          ),
          BottomNavigationBarItem(
            label: 'My Rides',
            icon: Icon(Icons.directions_car_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Account',
            icon: Icon(Icons.account_circle_outlined),
          ),
        ],
        currentIndex: _selectedItem,
        // OnTap, update our current index into `items` and rebuild ONLY this
        // specific widget. DOES NOT REBUILD Children!
        // See: https://stackoverflow.com/questions/57716056/indexedstack-widgets-are-not-updating
        onTap: (int index) async {
          // 1. User tapped a valid BottomNavBar Page (RideBoard, MyRides, Account)
          if ([0, 2, 3].contains(index)) {
            setState(() {
              _selectedItem = index;
            });
          }

          // 2. User tapped on "Post Ride" (index 1)
          else {
            bool isActiveDriver = tagAlongUserViewModel.isActiveDriver();
            logger.log
                .fine('RideBoardScreen - isActiveDriver: $isActiveDriver');
            // If Active Driver, go to `Offer Ride Page`
            if (isActiveDriver) {
              logger.log.fine('RideBoardScreen - Going to OfferRideCampus');
              Navigator.pushNamed(context, '/offer_ride_campus');
            }
            // If NOT Active Driver, offer option to register as such
            else {
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text('Not a Driver'),
                        content: const Text(
                            'You’re almost ready to post rides! Create your driver profile to get started.'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                                Navigator.pushReplacementNamed(
                                    context, '/register_driver');
                              },
                              child: const Text('OK')),
                        ]);
                  });
            }
          }
        });
  }
}
