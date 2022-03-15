import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    String email = tagAlongUserViewModel.tagAlongUser!.emailAddress;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TagAlong')
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 150
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Welcome to TagAlong!')
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('We sent a confirmation email to:')
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(email)
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Check your school email and click the link to'
                        ' get started!')
                ),
              ]
            )
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  onPressed: () async {
                    // TODO: Testing email verification
                    await tagAlongUserViewModel.getUser()?.reload();
                    logger.log.fine(tagAlongUserViewModel.getUser()?.emailVerified);

                    Navigator.pushReplacementNamed(context, '/driver_registration_prompt');
                  },
                  child: const Text('OK'),
                ),
              ),
            ),
          )
        ]
      )
    );
  }
}
