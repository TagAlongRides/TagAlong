import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/login_screen.dart';
import 'package:tagalong/screens/register_user_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/util/log.dart' as logger;

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get our AuthService
    var auth_service = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder(
      stream: auth_service.currentUser,
      builder: (context, snapshot) {
        // Gotten data - check if user is logged in
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          // User is LOGGED OUT
          if (user == null) {
            logger.log.fine('User is logged OUT - going to LoginScreen');
            return LoginScreen();
          }
          // User is LOGGED IN
          else {
            logger.log.fine('User is logged IN - Checking registration');
            // User is registered
            if (_is_registered() == true) {
              logger.log.fine('User is registered');
              return const RideBoardScreen();
            }
            // User is NOT registered
            else {
              logger.log.fine('User is NOT registered - '
                  'going to RegisterUserScreen');
              logger.log.fine('User JSON - $user');
              return RegisterUserScreen();
            }
          }
        }
        // Have not gotten data - progress indicator
        else {
          logger.log.fine('Waiting for data - CircularProgressIndicator');
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  /*
  _is_registered() will ask Firebase to see if a user is registered
  * TODO: Add async realtime functionality
  */
  bool _is_registered() {
    logger.log.fine('is_registered: false');
    return false;
  }
}
