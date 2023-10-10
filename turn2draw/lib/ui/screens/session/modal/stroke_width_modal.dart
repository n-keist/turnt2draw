import 'package:flutter/material.dart';

class SessionStrokeWidthModal extends StatelessWidget {
  const SessionStrokeWidthModal({super.key, required this.strokeWidthNotifier});

  final ValueNotifier<double> strokeWidthNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ValueListenableBuilder(
        valueListenable: strokeWidthNotifier,
        builder: (context, value, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: Colors.blue,
                thickness: value,
              ),
              const SizedBox(height: 24.0),
              Slider.adaptive(
                value: value,
                min: 1.0,
                max: 25.0,
                onChanged: (value) => strokeWidthNotifier.value = value,
              ),
            ],
          );
        },
      ),
    );
  }
}
