import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'driver_registration/color_drop_down_button.dart';
import 'driver_registration/make_drop_down_button.dart';
import 'driver_registration/model_drop_down_button.dart';
import 'driver_registration/year_drop_down_button.dart';
import 'package:tagalong/util/log.dart' as logger;


/// This widget will be in charge of checking the [RegisterDriverViewModel] to
/// determine the current state/progress of the driver registration process.
/// Depending on the state, it will render different widgets:
/// 1. A true <data>DropDownButton
/// 2. A fake disabled DropDownButton
class DriverRegistrationForm extends StatefulWidget {
  const DriverRegistrationForm({Key? key}) : super(key: key);

  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    // Will rebuild on any state change from the ViewModel
    RegisterDriverViewModel _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: true);
    bool _showModelDropDownButton = (_registerDriverViewModel.make != null);
    bool _showYearDropDownButton = (_showModelDropDownButton && _registerDriverViewModel.model != null);
    bool _showColorDropDownButton = (_showYearDropDownButton && _registerDriverViewModel.year != null);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Make
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: MakeDropDownButtonWidget()
                ),

                // 2. Model - dependant on Make
                if (_showModelDropDownButton)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ModelDropDownButton()
                  ),

                // 3. Year - dependant on Make & Model
                if (_showYearDropDownButton)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: YearDropDownButton()
                  ),

                // 4. Color - A static enum list therefore no async
                if (_showColorDropDownButton)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ColorDropDownButton()
                  )
              ]
            ),
          ),

          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // // TODO: Need a better way of doign this?
                  // Map<String, dynamic> driverData = {
                  //   'is_driver': true,
                  //   'car_make': makeValue,
                  //   'car_model': modelValue,
                  //   'car_year': yearValue,
                  //   'car_color': colorValue
                  // };
                  // logger.log.fine(driverData.toString());
                  // tagAlongUserViewModel.updateTagAlongUser(driverData);
                  // Navigator.pushReplacementNamed(context, '/ride_board');
                },
                child: const Text('Let\'s Go!'),
              )
            ),

          )
        ]
      )
    );
  }
}
