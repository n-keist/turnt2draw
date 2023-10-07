part of '../word_repository.dart';

class HttpSharedPreferencesWordRepository implements WordRepository {
  HttpSharedPreferencesWordRepository({SharedPreferences? preferences, http.Client? client})
      : preferences = preferences ?? UnimplementedPreferences(),
        client = client ?? http.Client();

  final SharedPreferences preferences;
  final http.Client client;

  @override
  Future<void> fetchAllWords() async {
    for (final type in WordType.values) {
      await fetchWords(type: type);
    }
  }

  @override
  Future<void> fetchWords({WordType type = WordType.topic}) async {
    try {
      final eTag = preferences.getString(type.getPreferenceETagKey());

      final response = await client.get(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/words/word',
          queryParameters: {
            'type': type.getHttpKey(),
          },
        ),
        headers: {
          if (eTag != null) 'If-None-Match': eTag,
        },
      );

      if (response.statusCode != 200) return;
      final json = jsonDecode(response.body);
      final List<String> words = json.map<String>((word) => '$word').toList(growable: false);

      final storeResult = await preferences.setStringList(
        type.getPreferenceKey(),
        words,
      );

      if (!storeResult) throw 'unable to store word type "${type.getPreferenceKey()}"';

      final responsETagValue = response.headers['etag'];

      if (responsETagValue != null) {
        await preferences.setString(type.getPreferenceETagKey(), responsETagValue);
      }
    } catch (e) {
      logger.e('COULD NOT FETCH WORDS', error: e);
    }
  }

  @override
  Future<List<String>> getWords({WordType type = WordType.topic}) async {
    final key = type.getPreferenceKey();

    final words = preferences.getStringList(key);
    return words ?? <String>[];
  }
}
