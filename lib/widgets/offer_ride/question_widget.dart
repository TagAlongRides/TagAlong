import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final String question;

  const QuestionWidget({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        question,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
