import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:turn2draw/data/repository/word_repository.dart';

import '../mock/http_client_mock.dart';
import '../mock/shared_preferences_mock.dart';

void main() {
  final preferences = MockSharedPreferences();
  final client = MockClient();

  late WordRepository repository;

  setUp(() {
    reset(preferences);
    reset(client);

    repository = HttpSharedPreferencesWordRepository(client: client, preferences: preferences);
  });

  setUpAll(() => registerFallbackValue(FakeUri()));

  group('#fetchWords', () {
    test('get topic list', () async {
      when(() => preferences.getString(any())).thenAnswer((_) => 'some-e-tag');
      when(() => preferences.setString(any(), any())).thenAnswer((_) async => true);
      when(() => preferences.setStringList(any(), any())).thenAnswer((_) async => true);

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => Response('["some", "word", "list"]', 200),
      );

      await repository.fetchWords();

      verify(() => preferences.setStringList(any(), any()));
    });

    test('get topic list throws', () async {
      when(() => preferences.getString(any())).thenAnswer((_) => 'some-e-tag');
      when(() => preferences.setString(any(), any())).thenAnswer((_) async => true);
      when(() => preferences.setStringList(any(), any())).thenAnswer((_) async => true);

      when(() => client.get(any(), headers: any(named: 'headers'))).thenThrow('some error');

      await repository.fetchWords();

      verifyNever(() => preferences.setStringList(any(), any()));
    });

    test('get noun list', () async {
      when(() => preferences.getString(any())).thenAnswer((_) => 'some-e-tag');
      when(() => preferences.setString(any(), any())).thenAnswer((_) async => true);
      when(() => preferences.setStringList(any(), any())).thenAnswer((_) async => true);

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => Response('["some", "word", "list"]', 200),
      );

      await repository.fetchWords(type: WordType.noun);

      verify(() => preferences.setStringList(any(), any()));
    });

    test('get adjective list (with e tag)', () async {
      when(() => preferences.getString(any())).thenAnswer((_) => 'some-e-tag');
      when(() => preferences.setString(any(), any())).thenAnswer((_) async => true);
      when(() => preferences.setStringList(any(), any())).thenAnswer((_) async => true);

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => Response(
          '["some", "word", "list"]',
          200,
          headers: {
            'etag': 'some-e-tag',
          },
        ),
      );

      await repository.fetchWords(type: WordType.adjective);

      verify(() => preferences.setStringList(any(), any()));
      verify(() => preferences.setString(any(), 'some-e-tag'));
    });
  });

  group('#getWords', () {
    test('null', () async {
      when(() => preferences.getStringList(any())).thenAnswer((_) => null);
      expect(await repository.getWords(), []);
    });

    test('topic', () async {
      when(() => preferences.getStringList(any())).thenAnswer((_) => ['a', 'b']);
      expect(await repository.getWords(), ['a', 'b']);
    });
    test('noun', () async {
      when(() => preferences.getStringList(any())).thenAnswer((_) => ['a', 'b']);
      expect(await repository.getWords(type: WordType.noun), ['a', 'b']);
    });
    test('adj', () async {
      when(() => preferences.getStringList(any())).thenAnswer((_) => ['a', 'b']);
      expect(await repository.getWords(type: WordType.adjective), ['a', 'b']);
    });
  });
}
