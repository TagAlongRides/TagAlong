import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
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
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    logger.log.fine('RideboardScreen - In Ride Board!');
    logger.log.fine('RideboardScreen - ${tagAlongUserViewModel.tagAlongUser?.toJson()}');

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
          // BottomNavigationBarItem(
          //   label: 'Messages',
          //   icon: Icon(Icons.message_outlined),
          // ),
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
        onPressed: () {  },
        child: const Icon(Icons.add)
      ),
    );
  }
}
