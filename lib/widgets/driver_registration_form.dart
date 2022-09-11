import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/screens/stripe_connect_registration/driver_stripe_connect_registration_screen.dart';
import 'package:tagalong/screens/stripe_connect_registration/stripe_info_screen.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

import 'driver_registration/color_drop_down_button.dart';
import 'driver_registration/make_drop_down_button.dart';
import 'driver_registration/model_drop_down_button.dart';
// import 'driver_registration/year_drop_down_button.dart';

/// This widget will be in charge of checking the [RegisterDriverViewModel] to
/// determine the current state/progress of the driver registration process.
/// Depending on the state, it will render different widgets:
/// 1. A true <data>DropDownButton
/// 2. A fake disabled DropDownButton
class DriverRegistrationForm extends StatefulWidget {
  // final Driver? driver;
  const DriverRegistrationForm({Key? key}) : super(key: key);

  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  StripeConnectResponse? _connectResponse;

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    final _deviceWidth = MediaQuery.of(context).size.width;
    final _tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    final _userVehicle = _tagAlongUserViewModel.tagAlongUser?.driverData?.vehicle;

    // Will rebuild on any state change from the ViewModel
    final _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: true);

    bool _showModelDropDownButton = (_registerDriverViewModel.make != null || _userVehicle?.make != null);
    // bool _showYearDropDownButton = (_showModelDropDownButton && _registerDriverViewModel.model != null);
    bool _showColorDropDownButton =
        (_showModelDropDownButton && _registerDriverViewModel.model != null || _userVehicle?.model != null);

    Future<void> _handlePress() async {
      if (_formKey.currentState!.validate()) {
        // 1. Create [Driver] instance
        Driver? driver = _registerDriverViewModel.createDriver();

        if (driver == null) {
          logger.log.fine('DriverRegistrationForm - Driver not valid?');
        } else {
          // 1. Update our [TagAlongUser] in-memory
          Map<String, dynamic> data = {'driver_data': driver};
          _tagAlongUserViewModel.updateTagAlongUserInternal(data);

          // 2. Update [TagAlongUser] in Firestore
          _tagAlongUserViewModel.updateTagAlongUserFirestore();

          Navigator.of(context).pushNamed(StripeInfoScreen.routeName);
        }
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 1. Make
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: MakeDropDownButtonWidget(_userVehicle?.make),
                ),

                // 2. Model - dependant on Make
                if (_showModelDropDownButton)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ModelDropDownButton(_userVehicle?.model),
                  ),

                // 3. Year - dependant on Make & Model
                // if (_showYearDropDownButton)
                //   Padding(padding: const EdgeInsets.symmetric(vertical: 16.0), child: YearDropDownButton()),

                // 4. Color - A static enum list therefore no async
                if (_showColorDropDownButton)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ColorDropDownButton(_userVehicle?.color),
                  )
              ]),
            ),
          ),
          SizedBox(
            width: _deviceWidth * .80,
            child: ElevatedButton(
              onPressed: _registerDriverViewModel.make != null &&
                      _registerDriverViewModel.model != null &&
                      _registerDriverViewModel.color != null
                  ? _handlePress
                  : null,
              child: const Text('Continue to Payment Setup'),
            ),
          ),
        ],
      ),
    );
  }
}
