abstract class LocalStorage {
  Future<void> write<T>(String key, T value);

  Future<T> read<T>(String key);
}
