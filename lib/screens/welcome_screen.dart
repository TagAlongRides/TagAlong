import 'package:flutter/material.dart';
import 'package:tagalong/util/log.dart' as logger;


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome')
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 40
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Welcome to TagAlong!')
                  )
                ]
              )
            )
          ),

          ElevatedButton(
            onPressed: () {
              logger.log.fine('dasf');
            },
            child: const Text('OK'),

          )
        ]
      )
    );
  }
}
