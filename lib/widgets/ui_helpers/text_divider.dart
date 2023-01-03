import 'package:flutter/material.dart';

/// A horizontal Material divider that inserts a Text widget in the middle.
class TextDivider extends StatelessWidget {
  final String middleText;

  const TextDivider({Key? key, required this.middleText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  thickness: 1.0,
                ),
              )
          ),
          Text(middleText),
          const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  thickness: 1.0,
                ),
              )
          ),
        ]
    );
  }
}