import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/data/model/settings.dart';
import 'package:turn2draw/data/service/settings_service.dart';
import 'package:turn2draw/storage/impl/in_memory_local_storage.dart';
import 'package:turn2draw/storage/local_storage.dart';

class SharedPreferencesSettingsService extends SettingsService {
  SharedPreferencesSettingsService({LocalStorage? storage}) : storage = storage ?? InMemoryLocalStorage();

  final LocalStorage storage;

  Settings _settings = const Settings();

  @override
  Future<Settings> getCurrentSettingsState() async {
    final hapticFeedback = await storage.read<bool?>(pSettingsHapticFeed);
    return Settings(
      hapticFeedback: hapticFeedback ?? false,
    );
  }

  @override
  Future<void> setSettingsProperty<T>(String key, T value) async {
    await storage.write<T>(key, value);
    _settings = await getCurrentSettingsState();
    notifyListeners();
  }

  @override
  Settings get settings => _settings;

  @override
  Future<void> load() => getCurrentSettingsState();
}
