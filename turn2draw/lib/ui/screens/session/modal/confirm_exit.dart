import 'package:flutter/widgets.dart';
import 'package:turn2draw/ui/common/dialog/message_dialog.dart';

class ConfirmExitModal extends StatelessWidget {
  const ConfirmExitModal({super.key});

  @override
  Widget build(BuildContext context) {
    return MessageDialog(
      title: 'Are you sure?',
      body: 'Exiting this game may result in the game being exited early.',
      callbackText: 'YES I AM SURE',
      callback: () => Navigator.of(context).pop(true),
    );
  }
}
