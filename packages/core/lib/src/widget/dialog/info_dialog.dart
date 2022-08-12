import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog(
      {Key? key,
      required this.message,
      this.negativeLabel = 'Cancel',
      this.positiveLabel,
      this.negativePress,
      this.positivePress})
      : super(key: key);
  final String message;
  final String negativeLabel;
  final String? positiveLabel;
  final VoidCallback? negativePress;
  final VoidCallback? positivePress;

  static Future show(
    BuildContext context, {
    required String message,
    String negativeLabel = 'Cancel',
    String? positiveLabel,
    VoidCallback? negativePress,
    VoidCallback? positivePress,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return InfoDialog(
          message: message,
          negativeLabel: negativeLabel,
          positiveLabel: positiveLabel,
          negativePress: negativePress,
          positivePress: positivePress,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;
    return Center(
      child: Container(
        padding:
            const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 12),
        margin: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(6),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: negativePress ??
                        () {
                          Navigator.of(context).pop();
                        },
                    child: Text(negativeLabel),
                  ),
                  if (positiveLabel != null)
                    TextButton(
                      onPressed: positivePress ?? () {},
                      child: Text(positiveLabel!),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
