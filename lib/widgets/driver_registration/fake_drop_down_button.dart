import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;


class FakeDropDownButton extends StatefulWidget {
  String label;

  FakeDropDownButton({Key? key, required this.label}) : super(key: key);

  @override
  _FakeDropDownButtonState createState() => _FakeDropDownButtonState();
}

class _FakeDropDownButtonState extends State<FakeDropDownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: "",
      items: const [
        DropdownMenuItem
          (
            child: Text(""),
            value: ""
        )
      ],
      onChanged: null,
    );
  }
}
