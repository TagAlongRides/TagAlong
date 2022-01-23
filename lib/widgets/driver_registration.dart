import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';

class DriverRegistrationForm extends StatefulWidget {
  const DriverRegistrationForm({Key? key}) : super(key: key);

  @override
  _DriverRegistrationFormState createState() => _DriverRegistrationFormState();
}

class _DriverRegistrationFormState extends State<DriverRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  // TODO: Enum Changes
  String? makeValue = 'Car Make';
  String? modelValue = 'Car Model - dependant on Make';
  String? yearValue = 'Car Year';
  String? colorValue = 'Car Color';


  @override
  Widget build(BuildContext context) {
    TagAlongUserViewModel tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            // 1. Make
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: DropdownButtonFormField<String>(
                value: makeValue,
                decoration: const InputDecoration(
                  icon: Icon(Icons.directions_car_outlined),
                  labelText: 'Car Make'
                ),
                items: const [
                  DropdownMenuItem<String>(
                      child: Text("Car Make"),
                      value: "Car Make"
                  )
                ],
                onChanged: (String? value) {
                  setState(() {
                    makeValue = value!;
                  });
                }
              )
            ),

            // 2. Model
            Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: DropdownButtonFormField<String>(
                    value: modelValue,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.model_training),
                        labelText: 'Car Model - dependant on Make'
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                          child: Text("Car Model - dependant on Make"),
                          value: "Car Model - dependant on Make"
                      )
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        modelValue = value!;
                      });
                    }
                )
            ),

            // 3. Year
            Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: DropdownButtonFormField<String>(
                    value: yearValue,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.directions_car_outlined),
                        labelText: 'Car Year'
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                          child: Text("Car Year"),
                          value: "Car Year"
                      )
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        yearValue = value!;
                      });
                    }
                )
            ),

            // 4. Color
            Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: DropdownButtonFormField<String>(
                    value: colorValue,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.directions_car_outlined),
                        labelText: 'Car Color'
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                          child: Text("Car Color"),
                          value: "Car Color"
                      )
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        colorValue = value!;
                      });
                    }
                )
            ),

            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Need a better way of doign this?
                  Map<String, dynamic> driverData = {
                    'is_driver': true,
                    'car_make': makeValue,
                    'car_model': modelValue,
                    'car_year': yearValue,
                    'car_color': colorValue
                  };
                  print(driverData.toString());
                  tagAlongUserViewModel.updateTagAlongUser(driverData);
                  Navigator.pushReplacementNamed(context, '/ride_board');
                },
                child: const Text("Let's go!"),
              )
            )
          ]
        )
      )
    );
  }
}

