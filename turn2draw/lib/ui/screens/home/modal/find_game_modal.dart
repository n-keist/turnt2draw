import 'package:flutter/material.dart';
import 'package:turn2draw/ui/common/input/wide_button.dart';

class FindGameModal extends StatelessWidget {
  FindGameModal({super.key}) : controller = TextEditingController();

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GAME CODE',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '(typically A-F & 0-9), visible during the waiting period',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TextField(
            controller: controller,
            maxLength: 5,
            autofocus: true,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                  style: BorderStyle.none,
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              bool enabled = controller.text.length == 5;
              return WideButton(
                color: !enabled ? Colors.grey.shade400 : Colors.purple,
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                foregroundColor: Colors.white,
                label: 'FIND',
                callback: enabled ? () => Navigator.of(context).pop(controller.text) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
