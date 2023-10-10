import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SessionColorPickerModal extends StatelessWidget {
  const SessionColorPickerModal({super.key, required this.colorNotifier});
  final ValueNotifier<Color> colorNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ColorPicker(
            pickerColor: colorNotifier.value,
            paletteType: PaletteType.hueWheel,
            enableAlpha: false,
            labelTypes: const [],
            onColorChanged: (color) => colorNotifier.value = color,
            pickerAreaBorderRadius: BorderRadius.circular(12.5),
          ),
          const SizedBox(height: 12.0),
          FloatingActionButton.small(
            onPressed: () => Navigator.of(context).pop(),
            heroTag: 'PICK_COLOR',
            child: const Icon(Icons.check_rounded),
          ),
        ],
      ),
    );
  }
}
