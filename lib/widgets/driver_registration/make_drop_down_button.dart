import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/viewmodels/register_driver_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/widgets/driver_registration/dropdown_options.dart';

class MakeDropDownButtonWidget extends StatefulWidget {
  final String? initValue;
  const MakeDropDownButtonWidget(this.initValue, {Key? key}) : super(key: key);

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
    if (widget.initValue != null) {
      // Seeding notifies listeners, which the form is one of; doing that
      // during initState rebuilds it mid-build. Wait for the frame to end.
      // Make, model and color seed in that order, so each one's reset of the
      // next field still lands before that field is seeded.
      final initValue = widget.initValue!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _registerDriverViewModel.updateMake(make: initValue);
      });
    }
    makeList = _registerDriverViewModel.getMakes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: makeList,
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return const Center(child: CircularProgressIndicator());
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Car Make'),
              value: null,
              items: null,
              disabledHint: _registerDriverViewModel.make != null ? Text(_registerDriverViewModel.make!) : null,
              // When user chooses option, update our ViewModel's `make` which
              // will automatically cause a rebuild from `NewDriverRegistration`,
              // therefore the new `DropdownButton.value` will automatically be updated.
              onChanged: null,
            );
          } else if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
            // Previously this branch was unreachable: `done` was checked
            // first and matched even when the future had failed, leaving an
            // empty dropdown with no explanation and no way forward.
            logger.log.warning('Could not load car makes: ${snapshot.error}');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We could not load the list of car makes right now.',
                  style: TextStyle(color: Colors.red),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                  onPressed: () => setState(() {
                    makeList = _registerDriverViewModel.getMakes();
                  }),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            logger.log.fine('Done!');
            // By this time, `makeList` is a completed Future and contains
            // a List<String> of ALL makes
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: 'Car Make'),
              value: _registerDriverViewModel.make,
              items: withCurrent(snapshot.data!, _registerDriverViewModel.make)
                  .map((makeOption) => DropdownMenuItem<String>(child: Text(makeOption), value: makeOption))
                  .toList(),
              // When user chooses option, update our ViewModel's `make` which
              // will automatically cause a rebuild from `NewDriverRegistration`,
              // therefore the new `DropdownButton.value` will automatically be updated.
              onChanged: (String? chosenMake) {
                _registerDriverViewModel.updateMake(make: chosenMake!);
              },
            );
          } else {
            return const Text('Some problem...');
          }
        });
  }
}
