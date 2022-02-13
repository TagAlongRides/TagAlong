import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

class MakeDropDownButtonWidget extends StatefulWidget {
  const MakeDropDownButtonWidget({Key? key}) : super(key: key);

  @override
  _MakeDropDownButtonWidgetState createState() => _MakeDropDownButtonWidgetState();
}

class _MakeDropDownButtonWidgetState extends State<MakeDropDownButtonWidget> {
  late RegisterDriverViewModel _registerDriverViewModel;
  late Future<List<String>> makeList;

  @override
  void initState() {
    super.initState();
    // Prepare our car make list within initState for FutureBuilder
    _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: false);
    makeList = _registerDriverViewModel.getMakes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: makeList,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot.connectionState == ConnectionState.done) {
          logger.log.fine('Done!');
          // By this time, `makeList` is a completed Future and contains
          // a List<String> of ALL makes
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Car Make'
            ),
            value: _registerDriverViewModel.make,
            items: snapshot.data?.map((makeOption) =>
              DropdownMenuItem<String>(
                child: Text(makeOption),
                value: makeOption
              )
            ).toList(),
            // When user chooses option, update our ViewModel's `make` which
            // will automatically cause a rebuild from `NewDriverRegistration`,
            // therefore the new `DropdownButton.value` will automatically be updated.
            onChanged: (String? chosenMake) {
              _registerDriverViewModel.updateMake(make:chosenMake!);
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
