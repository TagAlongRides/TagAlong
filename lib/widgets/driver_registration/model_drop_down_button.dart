import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

class ModelDropDownButton extends StatefulWidget {
  const ModelDropDownButton({Key? key}) : super(key: key);

  @override
  _ModelDropDownButtonState createState() => _ModelDropDownButtonState();
}

class _ModelDropDownButtonState extends State<ModelDropDownButton> {
  late RegisterDriverViewModel _registerDriverViewModel;
  late Future<List<String>> modelList;

  @override
  void initState() {
    super.initState();
    // Prepare our car model list within initState for FutureBuilder.
    // Note: This widget builds ONLY if `make` exists
    _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_registerDriverViewModel.hasMakeUpdated) {
      modelList = _registerDriverViewModel.getModels();
      _registerDriverViewModel.hasMakeUpdated = false;
    }
    return FutureBuilder<List<String>>(
        future: modelList,
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          else if (snapshot.connectionState == ConnectionState.done) {
            logger.log.fine('Done!');
            // By this time, `modelList` is a completed Future and contains
            // a List<String> of ALL models of said `make`
            return DropdownButtonFormField<String>(
              value: _registerDriverViewModel.model,
              items: snapshot.data?.map((modelOption) =>
                  DropdownMenuItem<String>(
                      child: Text(modelOption),
                      value: modelOption
                  )
              ).toList(),
              // When user chooses option, update our ViewModel's `make` which
              // will automatically cause a rebuild from `NewDriverRegistration`,
              // therefore the new `DropdownButton.value` will automatically be updated.
              onChanged: (String? chosenModel) {
                _registerDriverViewModel.updateModel(model:chosenModel!);
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
