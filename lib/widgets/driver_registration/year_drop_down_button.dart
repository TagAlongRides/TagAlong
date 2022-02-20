import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;


class YearDropDownButton extends StatefulWidget {
  const YearDropDownButton({Key? key}) : super(key: key);

  @override
  _YearDropDownButtonState createState() => _YearDropDownButtonState();
}

class _YearDropDownButtonState extends State<YearDropDownButton> {
  late RegisterDriverViewModel _registerDriverViewModel;
  late Future<List<String>> yearList;

  @override
  void initState() {
    super.initState();
    // Prepare our car model list within initState for FutureBuilder.
    // Note: This widget builds ONLY if `make` AND `model exists
    _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_registerDriverViewModel.hasModelUpdated) {
      yearList = _registerDriverViewModel.getYears();
      _registerDriverViewModel.hasModelUpdated = false;
    }
    return FutureBuilder<List<String>>(
        future: yearList,
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.connectionState == ConnectionState.done) {
            logger.log.fine('Done!');
            // By this time, `modelList` is a completed Future and contains
            // a List<String> of ALL models of said `make`
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Car Year'
              ),
              value: _registerDriverViewModel.year,
              items: snapshot.data?.map((yearOption) =>
                  DropdownMenuItem<String>(
                      child: Text(yearOption),
                      value: yearOption
                  )
              ).toList(),
              // When user chooses option, update our ViewModel's `make` which
              // will automatically cause a rebuild from `NewDriverRegistration`,
              // therefore the new `DropdownButton.value` will automatically be updated.
              onChanged: (String? chosenYear) {
                _registerDriverViewModel.updateYear(year:chosenYear!);
              },
            );
          }
          else {
            return const Text('Some problem...');
          }
        }
    );
  }
}
