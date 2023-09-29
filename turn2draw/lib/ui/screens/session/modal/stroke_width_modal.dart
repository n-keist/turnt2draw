import 'package:flutter/material.dart';

class SessionStrokeWidthModal extends StatefulWidget {
  const SessionStrokeWidthModal({super.key, this.value = 1.0});

  final double value;

  @override
  State<SessionStrokeWidthModal> createState() => _SessionStrokeWidthModalState();
}

class _SessionStrokeWidthModalState extends State<SessionStrokeWidthModal> {
  double value = 1.0;

  @override
  void initState() {
    setState(() => value = widget.value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) => Navigator.of(context).pop(value),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
              max: 10.0,
              onChanged: (value) => setState(() => this.value = value),
            ),
          ],
        ),
      ),
    );
  }
}
