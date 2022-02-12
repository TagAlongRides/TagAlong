import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'driver_registration/make_drop_down_button.dart';
import 'driver_registration/model_drop_down_button.dart';
import 'driver_registration/year_drop_down_button.dart';
import 'package:tagalong/util/log.dart' as logger;


/// This widget will be in charge of checking the [RegisterDriverViewModel] to
/// determine the current state/progress of the driver registration process.
/// Depending on the state, it will render different widgets:
/// 1. A true <data>DropDownButton
/// 2. A fake disabled DropDownButton
class NewDriverRegistrationForm extends StatefulWidget {
  const NewDriverRegistrationForm({Key? key}) : super(key: key);

  @override
  _NewDriverRegistrationFormState createState() => _NewDriverRegistrationFormState();
}

class _NewDriverRegistrationFormState extends State<NewDriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);

    // Will rebuild on any state change from the ViewModel
    RegisterDriverViewModel _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: true);
    bool _showModelDropDownButton = (_registerDriverViewModel.make != null);
    bool _showYearDropDownButton = (_registerDriverViewModel.make != null && _registerDriverViewModel.model != null);
    // bool _showModelDropDownButton = (_registerDriverViewModel.make != null && _registerDriverViewModel.model == null)
    //   || (_registerDriverViewModel.make != null && _registerDriverViewModel.model != null);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Make
            MakeDropDownButtonWidget(),

            // 2. Model - dependant on Make
            if (_showModelDropDownButton)
              ModelDropDownButton(),

            // 3. Year - dependant on Make & Model
            if (_showYearDropDownButton)
              YearDropDownButton()
          ]
        )
      )
    );
  }
}
