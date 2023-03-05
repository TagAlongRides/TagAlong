import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/util/form_sequence_utils.dart';
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:tagalong/viewmodels/register_user_view_model.dart';

/// [RegGradYearScreen] is a Screen that contains a Form for receiving the graduation year
class RegGradYearScreen extends StatefulWidget {

  const RegGradYearScreen({Key? key}) : super(key: key);

  @override
  State<RegGradYearScreen> createState() => _RegGradYearScreenState();
}

class _RegGradYearScreenState extends State<RegGradYearScreen> {
  // Form state
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    RegisterUserViewModel vm = Provider.of<RegisterUserViewModel>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: theme.TagAlongTheme.progressBarTheme.iconTheme,
            automaticallyImplyLeading: false,
            title: getProgressBarRow(filledIcons: 2, totalIcons: 4)
        ),
        body: Form(
          key: formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                              "What is your graduation year?"
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                        child: DropdownButtonFormField(
                            items: vm.gradYears.map<DropdownMenuItem<String>>((String? grad) {
                              return DropdownMenuItem<String>(value: grad, child: Text(grad ?? "N/A"));
                            }).toList(),
                            decoration: const InputDecoration(
                                // icon: Icon(Icons.school_rounded),
                                labelText: "Graduation Year (Optional)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                isDense: true
                            ),
                            onChanged: (value) {},
                            validator: vm.validateAndUpdateYear,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              size: 24.0,
                              semanticLabel: "Go Back",
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 24.0,
                              semanticLabel: "Move to next registration form",
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(context).pushNamed('reg/reg_email');
                              }
                            },
                          )
                        ]
                    )
                )
              ]
          ),
        )
    );
  }
}
