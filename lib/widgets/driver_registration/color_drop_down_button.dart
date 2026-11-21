import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/util/car_colors.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';

class ColorDropDownButton extends StatefulWidget {
  final String? initValue;
  const ColorDropDownButton(this.initValue, {Key? key}) : super(key: key);

  @override
  _ColorDropDownButtonState createState() => _ColorDropDownButtonState();
}

class _ColorDropDownButtonState extends State<ColorDropDownButton> {
  late RegisterDriverViewModel _registerDriverViewModel;

  @override
  void initState() {
    super.initState();
    _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: false);
    if (widget.initValue != null) {
      // Seeding notifies listeners, which the form is one of; doing that
      // during initState rebuilds it mid-build. Wait for the frame to end.
      // Make, model and color seed in that order, so each one's reset of the
      // next field still lands before that field is seeded.
      final initValue = widget.initValue!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _registerDriverViewModel.updateColor(color: initValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Car Color'),
        value: _registerDriverViewModel.color,
        items: CarColor.values
            .map((colorOption) => DropdownMenuItem<String>(child: Text(colorOption), value: colorOption))
            .toList(),
        onChanged: (String? chosenColor) {
          _registerDriverViewModel.updateColor(color: chosenColor!);
        });
  }
}
