import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:tagalong/screens/register_driver_screen.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import '../themes/tagalong_theme.dart';

class DriverRegistrationPromptScreen extends StatelessWidget {
  const DriverRegistrationPromptScreen({Key? key}) : super(key: key);
  static const routeName = '/driver_registration_prompt';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Would you like to register as a TagAlong Driver?',
                        style: TagAlongTheme.lightTextTheme.headline5!.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.attach_money_rounded,
                        size: 80,
                        color: TagAlongTheme.secondarySwatch,
                      ),
                      Icon(
                        Icons.directions_car_outlined,
                        size: 160,
                        color: TagAlongTheme.primarySwatch,
                      ),
                      Icon(
                        Icons.attach_money_rounded,
                        size: 80,
                        color: TagAlongTheme.secondarySwatch,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        child: Text(
                          'As a TagAlong driver:',
                          textAlign: TextAlign.left,
                          style: TagAlongTheme.lightTextTheme.subtitle1!,
                        ),
                      ),
                      BulletedList(
                        bulletType: BulletType.conventional,
                        boxShape: BoxShape.circle,
                        style: TagAlongTheme.lightTextTheme.subtitle2!,
                        listItems: const [
                          'Earn extra gas money by offering a ride to students going the same way as you are',
                          'Only give rides to students who have been verified through their school email address',
                          'Create & spark new connections with students from your school community',
                        ],
                      ),
                    ],
                  ),
                ],
              )),
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RegisterDriverScreen.routeName);
                    },
                    child: SizedBox(
                      width: screenWidth * .8,
                      child: const Text('Sure', textAlign: TextAlign.center),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RideBoardScreen.routeName);
                    },
                    child: SizedBox(
                      width: screenWidth * .8,
                      child: const Text('Skip driver registration for now', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
