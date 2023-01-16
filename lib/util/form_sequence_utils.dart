import 'package:flutter/material.dart';

/// A set of utilities related to any Form registration sequences.
///
/// User registration, offer ride, etc..


/// Returns a [Row] of [totalIcons] icons, in which only [filledIcons] are filled.
Row getProgressBarRow({required int filledIcons, required int totalIcons}) {
  return Row(
    children: List<Widget>.generate(totalIcons, (int index) {
      if (index < filledIcons) {
        return const Padding(
          padding: EdgeInsets.only(right:10),
          child: Icon(Icons.circle),
        );
      }
      else {
        return const Padding(
          padding: EdgeInsets.only(right:10),
          child: Icon(Icons.circle_outlined),
        );
      }
    })
  );
}