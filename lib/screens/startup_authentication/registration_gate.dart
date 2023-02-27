import 'package:flutter/material.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/screens/startup_authentication/reg_name_screen.dart';
import 'package:tagalong/services/user_service.dart';
import 'package:tagalong/util/log.dart' as logger;


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
  UserService us = serviceLocator.get<UserService>();

  // async op that the FutureBuilder is based on - prepares in-memory TagAlongUserNew
  late Future<bool> loadTagAlongUserResult;

  @override
  void initState() {
    super.initState();
    loadTagAlongUserResult = us.loadTagAlongUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: loadTagAlongUserResult,
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
              // Data was received (bool for status code)
              if (snapshot.hasData) {

                // User was loaded in successfully!
                if (snapshot.data == true) {
                  logger.log.fine('RegistrationGate - user was loaded in successfully!');

                  // User is verified - to Rideboard!
                  //if (us.tagalongUser.isEmailVerified == true) {
                  if (us.getFirebaseAuth().currentUser!.emailVerified == true) {
                    logger.log.fine('RegistrationGate - user is verified, headed to rideboard!');
                    return const Center(child: Text("RideboardScreen"));
                  }

                  // User is registered, but NOT verified - to VerificationScreen
                  else if (us.tagalongUser.isRegistered == true) {
                    logger.log.fine('RegistrationGate - user is registered, but not verified, headed to VerifyScreen!');
                    return const Center(child: Text("VerifyScreen"));
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
        //   onPressed: () async => await us.signOut(),
        // )
    // floatingActionButton: FloatingActionButton(
    //   onPressed: () { us.signOut(); },
    //
    //   ),
    );
  }
}



