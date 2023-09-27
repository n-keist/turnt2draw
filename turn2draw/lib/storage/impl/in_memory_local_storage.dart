import 'package:turn2draw/storage/local_storage.dart';

class InMemoryLocalStorage extends LocalStorage {
  final _storage = <String, dynamic>{};

  @override
  Future<T> read<T>(String key) async {
    return _storage[key];
  }

  @override
  Future<void> write<T>(String key, T value) async {
    _storage.putIfAbsent(key, () => value);
  }
}
