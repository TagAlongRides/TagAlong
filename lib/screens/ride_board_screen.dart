import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/screens/my_ride/my_ride_screen.dart';
import 'package:tagalong/screens/offer_ride/offer_ride_campus.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/themes/tagalong_theme.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/filter_ride_view_model.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/screens/account/account_settings_screen.dart';
import 'package:tagalong/widgets/rideboard/rideboard.dart';

class RideBoardScreen extends StatefulWidget {
  const RideBoardScreen({Key? key}) : super(key: key);
  static const routeName = '/ride_board';

  @override
  _RideBoardScreenState createState() => _RideBoardScreenState();
}

class _RideBoardScreenState extends State<RideBoardScreen> with SingleTickerProviderStateMixin {
  // Index for the IndexedStack, representing which Widget to show on the screen
  // based on the BottomNavBar. The initial Widget will be the [RideBoard].
  // Note: The [IndexedStack] maintains state, therefore the build for the
  // IndexedStack children only occurs once, and they all happen at the start.
  // Therefore if you want to [RideBoard, MyRides, Account] UI to show
  // new state, you must rebuild the specific Widget.
  int _selectedItem = 0;
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
  }

  @override
  Widget build(BuildContext context) {
    logger.log.fine('RideboardScreen Build');

    return Scaffold(
      appBar: _getAppBar(context),
      body: _getBody(context),
      bottomNavigationBar: _getBottomNavBar(context),
    );
  }

  /// Loads the Point B dropdown options for the direction currently selected.
  Future<void> _loadDestinationOptions(BuildContext context) async {
    final filterRideViewModel = Provider.of<FilterRideViewModel>(context, listen: false);
    final rideBoardViewModel = Provider.of<RideBoardViewModel>(context, listen: false);

    filterRideViewModel.setLoadingDestinations(true);
    final options = await rideBoardViewModel.getDestinationOptions(toCampus: filterRideViewModel.toCampus);
    filterRideViewModel.setDestinationOptions(options);
  }

  /// UI for the filter Modal Bottom Sheet and its corresponding functionality.
  ///
  /// The UI is built out of 6 main pieces:
  /// 1. The [AppBar]
  /// 2. To/From Campus [ChoiceChips]
  /// 3. Departure Date [TextFormField] + DateRangePicker
  /// 4. Day / Night [ChoiceChips]
  /// 5. Point B destination dropdown
  /// 6. Row of filter buttons
  Widget _getFilterModalBottomSheet(BuildContext context) {
    var filterRideViewModel = Provider.of<FilterRideViewModel>(context, listen: false);
    var rideBoardViewModel = Provider.of<RideBoardViewModel>(context, listen: false);

    return DraggableScrollableSheet(
      maxChildSize: 0.75,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return ListView(
          controller: scrollController, // Must use controller for draggability
          children: [
            // 1. AppBar
            AppBar(
              title: const Text('Filter Rides', style: TextStyle(color: Colors.black)),
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
            const Padding(padding: EdgeInsets.all(8), child: Text('Which way are you heading?')),
            Padding(
                padding: const EdgeInsets.all(8),
                child: Consumer<FilterRideViewModel>(builder: (context, filterRideViewModel, child) {
                  return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    ChoiceChip(
                      label: SizedBox(
                        width: 120,
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text('To Campus'),
                        ),
                      ),
                      selected: filterRideViewModel.toCampus,
                      onSelected: (bool selected) {
                        filterRideViewModel.toCampusChoice();
                        _loadDestinationOptions(context);
                      },
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
                        onSelected: (bool selected) {
                          filterRideViewModel.fromCampusChoice();
                          _loadDestinationOptions(context);
                        })
                  ]);
                })),

            const Divider(
              indent: 16,
              endIndent: 16,
            ),

            // 3. Departure Date [TextFormField] + DateRangePicker
            const Padding(padding: EdgeInsets.all(8), child: Text('When are you leaving?')),
            Padding(
              padding: const EdgeInsets.all(8),
              // "Consumer" listening for FilterRide updates
              child: Consumer<FilterRideViewModel>(builder: (context, filterRideViewModel, child) {
                return TextFormField(
                    enableInteractiveSelection: false,
                    readOnly: true,
                    decoration: InputDecoration(
                        hintText: filterRideViewModel.getFormattedDepartureDate(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                        suffixIcon: const Icon(Icons.date_range)),

                    // Show the DateRangePicker - a single day is a range whose
                    // start and end are the same date.
                    onTap: () async {
                      final now = DateTime.now();
                      final range = await showDateRangePicker(
                        context: context,
                        initialDateRange: filterRideViewModel.departureRange,
                        firstDate: DateTime(now.year, now.month, now.day),
                        // Drivers can post up to 6 months out.
                        lastDate: now.add(const Duration(days: 190)),
                        helpText: 'Select when you want to leave',
                      );
                      filterRideViewModel.updateDepartureRange(range);
                    });
              }),
            ),

            // 4. Day / Night ChoiceChips
            const Padding(padding: EdgeInsets.all(8), child: Text('What time of day?')),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Consumer<FilterRideViewModel>(builder: (context, filterRideViewModel, child) {
                return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.wb_sunny_outlined, size: 18),
                    label: const SizedBox(
                      width: 100,
                      child: Text('Day', textAlign: TextAlign.center),
                    ),
                    selected: filterRideViewModel.day,
                    onSelected: (_) => filterRideViewModel.toggleDay(),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.nightlight_outlined, size: 18),
                    label: const SizedBox(
                      width: 100,
                      child: Text('Night', textAlign: TextAlign.center),
                    ),
                    selected: filterRideViewModel.night,
                    onSelected: (_) => filterRideViewModel.toggleNight(),
                  ),
                ]);
              }),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Day is 6:00am - 5:59pm, night is 6:00pm - 5:59am. Pick both or neither to see all times.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),

            const Divider(
              indent: 16,
              endIndent: 16,
            ),

            // 5. Point B destination dropdown
            Consumer<FilterRideViewModel>(builder: (context, filterRideViewModel, child) {
              // The dropdown lists the non-campus end of the trip, which flips
              // depending on the direction the user picked above.
              final label = filterRideViewModel.toCampus ? 'Where are you coming from?' : 'Where are you going?';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text(label)),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: filterRideViewModel.loadingDestinations
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String?>(
                            value: filterRideViewModel.destination,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            hint: Text(filterRideViewModel.destinationOptions.isEmpty
                                ? 'No locations available'
                                : 'Anywhere'),
                            items: [
                              const DropdownMenuItem<String?>(value: null, child: Text('Anywhere')),
                              ...filterRideViewModel.destinationOptions.map(
                                (option) => DropdownMenuItem<String?>(value: option, child: Text(option)),
                              ),
                            ],
                            onChanged: filterRideViewModel.destinationOptions.isEmpty
                                ? null
                                : filterRideViewModel.updateDestination,
                          ),
                  ),
                ],
              );
            }),

            const Padding(
              padding: EdgeInsets.all(8),
              child: Divider(
                indent: 16,
                endIndent: 16,
              ),
            ),

            // 6. Row of filter buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Button to reset ALL filters to default
                ElevatedButton(onPressed: () => filterRideViewModel.resetAll(), child: const Text('Reset Filters')),

                // Button to update the user's Ride filters and re-query data,
                // updating the Rideboard
                ElevatedButton(
                    onPressed: () {
                      // 1. Pop the BottomModelSheet
                      Navigator.pop(context);

                      // 2. Hand the selections to the [RideBoardViewModel],
                      // which reloads the board only if they actually changed.
                      rideBoardViewModel.updateFilters(filterRideViewModel.toRideFilters());
                    },
                    child: const Text('Filter'))
              ],
            )
          ],
        );
      },
    );
  }

  /// Returns [RideBoardScreen] AppBar
  _getAppBar(BuildContext context) {
    switch (_selectedItem) {
      case 0:
        return AppBar(title: const Text('Ride Board'),
            // automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt_rounded),
                // Filtering Button
                onPressed: () {
                  // Show the sheet reflecting whatever is currently applied to
                  // the board, then fetch the destination options for it.
                  Provider.of<FilterRideViewModel>(context, listen: false)
                      .loadFrom(Provider.of<RideBoardViewModel>(context, listen: false).filters);
                  _loadDestinationOptions(context);

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
            ]);
        break;
      case 1:
        return null; // Should never get here
        break;
      case 2:
        return AppBar(
          title: const Text('My Rides'),
        );
        break;
      case 3:
        return AppBar(
          title: const Text('Account Settings'),
        );
        break;
      default:
        return null;
    }
  }

  /// Returns the [RideBoardScreen] body
  Widget _getBody(BuildContext context) {
    return TabBarView(
      controller: _tabController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        RideBoard(),
        Text(''), // This should never be shown - represents "Post Ride"
        MyRideScreen(),
        AccountSettingsScreen(),
      ],
    );
  }

  /// Returns the [RideBoardScreen] BottomNavigationBar
  Widget _getBottomNavBar(BuildContext context) {
    var tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    return Material(
      color: TagAlongTheme.primarySwatch.shade500,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue.shade900,
        unselectedLabelColor: Colors.blue.shade50,
        indicatorColor: Colors.blue.shade900,
        tabs: const [
          FittedBox(
            fit: BoxFit.cover,
            child: Tab(
              text: 'Ride Board',
              icon: Icon(Icons.home_outlined),
            ),
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Tab(
              text: 'Post Ride',
              icon: Icon(Icons.add),
            ),
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Tab(
              text: 'My Rides',
              icon: Icon(Icons.directions_car_outlined),
            ),
          ),
          FittedBox(
            fit: BoxFit.contain,
            child: Tab(
              text: 'Account',
              icon: Icon(Icons.account_circle_outlined),
            ),
          ),
        ],
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
          // TODO - Extract this to its own widget
          else {
            // print(AuthService().getUser()?.emailVerified);
            setState(() {
              _selectedItem = 0;
            });
            AuthService().reloadUser();
            var userViewModel = tagAlongUserViewModel;
            final _driverData = userViewModel.tagAlongUser?.driverData;

            if (!(_driverData?.isStripeActive ?? false) && _driverData?.stripeAccountId != null) {
              final stripeAccount = await StripeAccountRepository.instance.getAccount(_driverData!.stripeAccountId!);
              _driverData.isStripeActive = stripeAccount.data.canReceivePayouts;

              // 1. Update our [TagAlongUser] in-memory
              Map<String, dynamic> data = {'driver_data': _driverData};
              userViewModel.updateTagAlongUserInternal(data);

              // 2. Update [TagAlongUser] in Firestore
              await userViewModel.updateTagAlongUserFirestore();
            }

            bool hasDriverData = _driverData != null;
            bool isActiveDriver = tagAlongUserViewModel.isActiveDriver();
            bool isStripeActive = tagAlongUserViewModel.isStripeActive();
            bool isEmailVerified = tagAlongUserViewModel.isEmailVerified();
            logger.log.fine('RideBoardScreen - isActiveDriver: $isActiveDriver');

            // If NOT Active Driver, offer option to register as such
            if (!isEmailVerified) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Verify email'),
                    content: const Text(
                        'To keep your travel safe, Tagalong requires every user to verify their email address before posting or booking a ride.'),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            userViewModel.sendEmailVerificationToUser();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Verification email sent to ${userViewModel.tagAlongUser?.emailAddress}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text('Resend Verification')),
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
                    ],
                  );
                },
              );
            } else if (!hasDriverData) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Not a Driver'),
                    content:
                        const Text('You’re almost ready to post rides! Create your driver profile to get started.'),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            Navigator.of(context).pushNamed(RegisterDriverScreen.routeName);
                          },
                          child: const Text('Create profile')),
                    ],
                  );
                },
              );
            } else if (hasDriverData && !isStripeActive) {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('We couldn' 't collect your payment details'),
                    content: const Text(
                        'Oops! There was an issue with your Stripe registration, please try registering again.'),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Not now')),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            Navigator.of(context).pushNamed(RegisterDriverScreen.routeName);
                          },
                          child: const Text('Register')),
                    ],
                  );
                },
              );
            } else if (isStripeActive && isActiveDriver) {
              logger.log.fine('RideBoardScreen - Going to OfferRideCampus');
              Navigator.pushNamed(context, OfferRideCampus.routeName);
            }
          }
        },
      ),
    );
  }
}
