import 'package:flutter/material.dart';
import 'package:tagalong/locator.dart';
import 'package:tagalong/screens/driver_registration_prompt_screen.dart';
import 'package:tagalong/util/form_sequence_utils.dart';
import 'package:user_repo/user_repo.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);
  static const routeName = '/welcome_screen';

  @override
  Widget build(BuildContext context) {

    UserRepository userRepo = serviceLocator.get<UserRepository>();
    String email = userRepo.getTagAlongUser().emailAddress!;

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
            automaticallyImplyLeading: false,
            title: getProgressBarRow(filledIcons: 4, totalIcons: 4)
        ),
        body: Column(children: [
          Expanded(
              flex: 4,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.mark_email_unread_outlined, size: 160),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Welcome to TagAlong!')),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('We sent a confirmation email to:')),
                Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(email)),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Check your school email and click the link to get started!')),
              ])),
          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  onPressed: () async {

                    // TODO: Testing email verification
                    // Need to reloadUser() on the FirebaseAuth [User] instance because
                    // the user may have verified their email after clicking this Button
                    await userRepo.reloadUser();

                    Navigator.pushReplacementNamed(context, DriverRegistrationPromptScreen.routeName);
                  },
                  child: const Text('OK'),
                ),
              ),
            ),
          )
        ]));
  }
}
