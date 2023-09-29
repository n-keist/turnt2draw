import 'package:flutter/material.dart';
import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/data/service/settings_service.dart';
import 'package:turn2draw/locator.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      children: [
        ListTile(
          title: const Text('Regenerate Username'),
          trailing: IconButton.filledTonal(
            onPressed: () => false,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
        ListenableBuilder(
          listenable: locator<SettingsService>(),
          builder: (context, _) {
            return SwitchListTile.adaptive(
              title: const Text('Haptic Feedback'),
              value: locator<SettingsService>().settings.hapticFeedback,
              onChanged: (value) => locator<SettingsService>().setSettingsProperty(pSettingsHapticFeed, value),
            );
          },
        ),
      ],
    );
  }
}