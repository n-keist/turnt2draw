import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/data/model/settings.dart';
import 'package:turn2draw/data/unimplemented_preferences.dart';

part 'impl/shared_preferences_settings_service.dart';

abstract class SettingsService with ChangeNotifier {
  Future<void> load();

  Future<Settings> getCurrentSettingsState();

  Future<void> setHapticFeedback(bool hapticFeedback);

  Settings get settings;
}
