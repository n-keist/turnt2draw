import 'package:flutter/foundation.dart';
import 'package:turn2draw/data/model/settings.dart';

abstract class SettingsService extends ChangeNotifier {
  Future<void> load();

  Future<Settings> getCurrentSettingsState();

  Future<void> setSettingsProperty<T>(String key, T value);

  Settings get settings;
}
