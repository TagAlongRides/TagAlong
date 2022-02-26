import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import 'package:tagalong/widgets/rideboard.dart';
import 'package:tagalong/widgets/account.dart';
import '../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

import '../widgets/myrides.dart';

class RideBoardScreen extends StatefulWidget {
  const RideBoardScreen({Key? key}) : super(key: key);

  @override
  _RideBoardScreenState createState() => _RideBoardScreenState();
}

class _RideBoardScreenState extends State<RideBoardScreen> {
  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    RideBoardViewModel rideBoardViewModel = Provider.of<RideBoardViewModel>(context, listen: false);
    // TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    logger.log.fine('RideboardScreen - In Ride Board!');
    // logger.log.fine('RideboardScreen - ${tagAlongUserViewModel.tagAlongUser?.toJson()}');


    return Scaffold(
      appBar: AppBar(
        title: const Text('Rideboard'),
        actions: [
          ElevatedButton(
              onPressed: () {
                authService.signOut();
              },
              child: const Text('Sign Out')
          )
        ]
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedItem,
          children: const [
            RideBoardList(),
            MyRides(),
            Account()
          ]
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            label: 'Ride Board',
            icon: Icon(Icons.home_outlined),
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
        // OnTap, update our current index into `items` and rebuild
        onTap: (int index) {
          setState(() {
            _selectedItem = index;
          });
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool isActiveDriver = await rideBoardViewModel.isActiveDriver();
          logger.log.fine('RideBoardScreen - isActiveDriver: $isActiveDriver');
          // If Active Driver, go to `Offer Ride Page`
          if (isActiveDriver) {
            logger.log.fine('RideBoardScreen - Going to OfferRideScreen');
            Navigator.pushNamed(context, '/offer_ride_campus');
          }
          // If NOT Active Driver, offer option to register as such
          else {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Not a Driver'),
                  content: const Text('You’re almost ready to post rides! Create your driver profile to get started.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.pushReplacementNamed(
                            context, '/register_driver');
                      },
                      child: const Text('OK')
                    ),
                  ]
                );
              }
            );
          }
        },
        child: const Icon(Icons.add)
      )
    );
  }
}
