import 'package:flutter/material.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/screens/startup_authentication/reg_name_screen.dart';
import 'package:tagalong/screens/welcome_screen.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:user_repo/user_repo.dart';


/// [RegistrationGate] is a Widget that performs conditional logic based on where
/// the end user is in their [TagAlongUserNew] registration process.
/// The logic is based on the results of async computation [loadTagAlongUser]
///
/// This widget can only be built if the end user is logged in, therefore the
/// [FirebaseAuth.currentUser] is NOT null at this time and can be guaranteed.
class RegistrationGate extends StatefulWidget {

  const RegistrationGate({Key? key}) : super(key: key);

  @override
  State<RegistrationGate> createState() => _RegistrationGateState();
}

class _RegistrationGateState extends State<RegistrationGate> {

  // UserService singleton - contains our singleton in-memory TagAlongUserNew
  UserRepository userRepo = serviceLocator.get<UserRepository>();

  // async op that the FutureBuilder is based on - prepares in-memory TagAlongUserNew
  late Future<TagAlongUser?> user;

  @override
  void initState() {
    super.initState();
    user = userRepo.loadTagAlongUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<TagAlongUser?>(
          future: user,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            logger.log.fine('loadTagAlongUserResult snapshot: ${snapshot.connectionState}');

            // 1. WAITING - async operation loading in the user
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. DONE - [loadTagAlongUser] has finished
            else if (snapshot.connectionState == ConnectionState.done) {

              // TODO: implement a ERROR screen
              if (snapshot.hasError) {
                return const Center(child: Text('Error'));
              }

              // MAIN branch!
              // Data was received (TagAlongUser instance)
              if (snapshot.hasData) {

                // Transform snapshot into [TagAlongUser]
                final TagAlongUser tagAlongUser = snapshot.data;

                // User was loaded in successfully!
                if (snapshot.data != null) {
                  logger.log.fine('RegistrationGate - user was loaded in successfully!');

                  // User is verified - to Rideboard!
                  if (userRepo.getFirebaseUser().emailVerified == true) {
                    logger.log.fine('RegistrationGate - user is verified, headed to rideboard!');
                    return const Center(child: Text("RideboardScreen"));
                  }

                  // User is registered, but NOT verified - to WelcomeScreen
                  else if (tagAlongUser.isRegistered == true) {
                    logger.log.fine('RegistrationGate - user is registered, but not verified, headed to VerifyScreen!');
                    return const WelcomeScreen();
                  }

                  // User is NOT registered - to RegForms
                  else {
                    logger.log.fine('RegistrationGate - user is NOT registered, headed to RegForms!');
                    return const RegNameScreen();
                  }
                }
                // TODO: implement a ERROR screen
                // User was NOT loaded in successfully!
                else {
                  logger.log.fine('RegistrationGate - user was NOT loaded in successfully!');
                }
                return Center(child: Text(snapshot.data.toString()));
              }
              else {
                return const Text('Empty data');
              }
            }

            // 3. SHOULD NOT HAPPEN WITH FutureBuilder
            else {
              return const Text("asdfasdfa");
            }
          }
        ),
      ),
    // floatingActionButton: FloatingActionButton(
    //   onPressed: () async { await userRepo.signOut(); },
    //
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: ()  { Navigator.pop(context); },
    //
    //   ),
    );
  }
}



