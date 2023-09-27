import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn2draw/storage/local_storage.dart';

class SharedPreferencesLocalStorage extends LocalStorage {
  SharedPreferencesLocalStorage({required this.preferences});

  final SharedPreferences preferences;

  @override
  Future<T> read<T>(String key) async {
    if (T is String || T is String?) return preferences.getString(key) as T;
    if (T is List<String> || T is List<String>?) return preferences.getStringList(key) as T;
    return preferences.get(key) as T;
  }

  @override
  Future<dynamic> write<T>(String key, T value) async {
    if (value is String) return await preferences.setString(key, value);
    if (value is List<String>) return await preferences.setStringList(key, value);
    throw UnimplementedError('storage type "${T.runtimeType.toString()}" is not implemented');
  }
}
