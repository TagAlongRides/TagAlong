import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: const [
                  Expanded(
                    child: Text("")
                  ),

                  Expanded(
                    child: Text("")
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}
