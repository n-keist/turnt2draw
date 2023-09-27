import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SessionColorPickerModal extends StatelessWidget {
  SessionColorPickerModal({super.key, this.lastColor = Colors.blue}) : selectedColor = ValueNotifier<Color>(lastColor);
  final Color lastColor;
  final ValueNotifier<Color> selectedColor;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ColorPicker(
              pickerColor: lastColor,
              paletteType: PaletteType.hueWheel,
              enableAlpha: false,
              labelTypes: const [],
              onColorChanged: (color) => selectedColor.value = color,
              pickerAreaBorderRadius: BorderRadius.circular(12.5),
            ),
            const SizedBox(height: 12.0),
            FloatingActionButton.small(
              onPressed: () => Navigator.of(context).pop(selectedColor.value),
              heroTag: 'PICK_COLOR',
              child: const Icon(Icons.check_rounded),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        Navigator.of(context).pop(selectedColor.value);
        return true;
      },
    );
  }
}
