import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/widgets/driver_registration/dropdown_options.dart';

class ModelDropDownButton extends StatefulWidget {
  final String? initValue;
  const ModelDropDownButton(this.initValue, {Key? key}) : super(key: key);

  @override
  _ModelDropDownButtonState createState() => _ModelDropDownButtonState();
}

class _ModelDropDownButtonState extends State<ModelDropDownButton> {
  late RegisterDriverViewModel _registerDriverViewModel;
  Future<List<String>>? modelList;

  @override
  void initState() {
    super.initState();
    // Prepare our car model list within initState for FutureBuilder.
    // Note: This widget builds ONLY if `make` exists
    _registerDriverViewModel = Provider.of<RegisterDriverViewModel>(context, listen: false);
    if (widget.initValue != null) {
      // Seeding notifies listeners, which the form is one of; doing that
      // during initState rebuilds it mid-build. Wait for the frame to end.
      // Make, model and color seed in that order, so each one's reset of the
      // next field still lands before that field is seeded.
      final initValue = widget.initValue!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _registerDriverViewModel.updateModel(model: initValue);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The saved make is seeded after the first frame, so on that frame there
    // may be no make to list models for yet.
    if (_registerDriverViewModel.make == null) {
      return DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Car Model'),
        value: null,
        items: null,
        onChanged: null,
      );
    }
    if (_registerDriverViewModel.hasMakeUpdated || modelList == null) {
      modelList = _registerDriverViewModel.getModels();
      // _registerDriverViewModel.hasMakeUpdated = false;
    }
    return FutureBuilder<List<String>>(
        future: modelList,
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return const Center(child: CircularProgressIndicator());
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Car Model'),
              value: null,
              disabledHint: _registerDriverViewModel.model != null ? Text(_registerDriverViewModel.model!) : null,
              items: null,
              onChanged: null,
            );
          } else if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
            logger.log.warning('Could not load car models: ${snapshot.error}');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We could not load models for that make right now.',
                  style: TextStyle(color: Colors.red),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                  onPressed: () => setState(() {
                    modelList = _registerDriverViewModel.getModels();
                  }),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            logger.log.fine('Done!');
            // By this time, `modelList` is a completed Future and contains
            // a List<String> of ALL models of said `make`
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Car Model'),
              value: _registerDriverViewModel.model,
              items: withCurrent(snapshot.data!, _registerDriverViewModel.model)
                  .map((modelOption) => DropdownMenuItem<String>(child: Text(modelOption), value: modelOption))
                  .toList(),
              // When user chooses option, update our ViewModel's `make` which
              // will automatically cause a rebuild from `NewDriverRegistration`,
              // therefore the new `DropdownButton.value` will automatically be updated.
              onChanged: (String? chosenModel) {
                _registerDriverViewModel.updateModel(model: chosenModel!);
              },
            );
          } else {
            return const Text('Some problem...');
          }
        });
  }
}
