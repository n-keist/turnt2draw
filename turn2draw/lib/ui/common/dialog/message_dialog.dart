import 'package:flutter/material.dart';
import 'package:turn2draw/ui/common/input/wide_button.dart';

class MessageDialog extends StatelessWidget {
  const MessageDialog({super.key, required this.title, required this.body, this.callback, this.callbackText = 'RETRY'});

  final String title;
  final String body;

  final VoidCallback? callback;
  final String callbackText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                body,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        WideButton(
          foregroundColor: Colors.white,
          label: callback != null ? callbackText : 'OKAY',
          callback: callback ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
