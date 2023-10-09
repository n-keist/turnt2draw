import 'package:flutter/material.dart';
import 'package:turn2draw/data/service/settings_service.dart';
import 'package:turn2draw/locator.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key, this.usernameCallback, this.iconCallback});

  final VoidCallback? usernameCallback;
  final VoidCallback? iconCallback;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      children: [
        ListTile(
          title: const Text('Raffle New Name'),
          trailing: IconButton.filledTonal(
            onPressed: usernameCallback,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
        ListTile(
          title: const Text('Raffle New Icon'),
          trailing: IconButton.filledTonal(
            onPressed: iconCallback,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
        ListenableBuilder(
          listenable: locator<SettingsService>(),
          builder: (context, _) {
            return SwitchListTile.adaptive(
              title: const Text('Haptic Feedback'),
              value: locator<SettingsService>().settings.hapticFeedback,
              onChanged: (value) => locator<SettingsService>().setHapticFeedback(value),
            );
          },
        ),
      ],
    );
  }
}
