import 'package:flutter/material.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/services/user_service.dart';
import 'package:tagalong/util/log.dart' as logger;

class RegistrationGate extends StatefulWidget {
  const RegistrationGate({Key? key}) : super(key: key);

  @override
  State<RegistrationGate> createState() => _RegistrationGateState();
}

class _RegistrationGateState extends State<RegistrationGate> {

  UserService us = serviceLocator.get<UserService>();
  late Future<String> loadTagAlongUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadTagAlongUser = us.queryAndLoadTagAlongUser();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: loadTagAlongUser,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          logger.log.fine('snapshot: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: const Text('Error'));
            }
            if (snapshot.hasData) {
              return Center(child: Text(snapshot.data));
            }
            else {
              return const Text('Empty data');
            }
          }
          else {
            return Text("asdfasdfa");
          }
        }
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async => await us.signOut(),
        )
    );
  }
}
