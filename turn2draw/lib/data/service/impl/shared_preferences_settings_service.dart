part of '../settings_service.dart';

class SharedPreferencesSettingsService extends SettingsService {
  SharedPreferencesSettingsService({SharedPreferences? preferences})
      : preferences = preferences ?? UnimplementedPreferences();

  final SharedPreferences preferences;

  Settings _settings = const Settings();

  @override
  Future<Settings> getCurrentSettingsState() async {
    final hapticFeedback = preferences.getBool(pSettingsHapticFeed);
    return Settings(
      hapticFeedback: hapticFeedback ?? false,
    );
  }

  @override
  Settings get settings => _settings;

  @override
  Future<void> load() async {
    final settings = await getCurrentSettingsState();
    _settings = settings;
    notifyListeners();
  }

  @override
  Future<void> setHapticFeedback(bool hapticFeedback) async {
    final saved = await preferences.setBool(pSettingsHapticFeed, hapticFeedback);
    if (saved) await load();
  }
}
