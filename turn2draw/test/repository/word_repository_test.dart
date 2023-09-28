import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:turn2draw/data/repository/word_repository.dart';

import '../mock/http_client_mock.dart';
import '../mock/local_storage_mock.dart';

void main() {
  final storage = MockLocalStorage();
  final client = MockClient();

  late WordRepository repository;

  setUp(() {
    reset(storage);
    reset(client);

    repository = WordRepository(storage: storage, client: client);
  });

  setUpAll(() => registerFallbackValue(FakeUri()));

  group('#fetchWords', () {
    test('get topic list', () async {
      when(() => storage.read<String?>(any())).thenAnswer((_) async => 'some-e-tag');
      when(() => storage.write<String>(any(), any())).thenAnswer((_) async {});
      when(() => storage.write<List<String>>(any(), any())).thenAnswer((_) async {});

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => Response('["some", "word", "list"]', 200),
      );

      await repository.fetchWords();

      verify(() => storage.write<List<String>>(any(), any()));
    });

    test('get topic list throws', () async {
      when(() => storage.read<String?>(any())).thenAnswer((_) async => 'some-e-tag');
      when(() => storage.write<String>(any(), any())).thenAnswer((_) async {});
      when(() => storage.write<List<String>>(any(), any())).thenAnswer((_) async {});

      when(() => client.get(any(), headers: any(named: 'headers'))).thenThrow('some error');

      await repository.fetchWords();

      verifyNever(() => storage.write<List<String>>(any(), any()));
    });

    test('get noun list', () async {
      when(() => storage.read<String?>(any())).thenAnswer((_) async => 'some-e-tag');
      when(() => storage.write<String>(any(), any())).thenAnswer((_) async {});
      when(() => storage.write<List<String>>(any(), any())).thenAnswer((_) async {});

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => Response('["some", "word", "list"]', 200),
      );

      await repository.fetchWords(type: WordType.noun);

      verify(() => storage.write<List<String>>(any(), any()));
    });

    test('get adjective list (with e tag)', () async {
      when(() => storage.read<String?>(any())).thenAnswer((_) async => 'some-e-tag');
      when(() => storage.write<String>(any(), any())).thenAnswer((_) async {});
      when(() => storage.write<List<String>>(any(), any())).thenAnswer((_) async {});

      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => Response(
          '["some", "word", "list"]',
          200,
          headers: {
            'E-Tag': 'some-e-tag',
          },
        ),
      );

      await repository.fetchWords(type: WordType.adjective);

      verify(() => storage.write<List<String>>(any(), any()));
      verify(() => storage.write<String>(any(), 'some-e-tag'));
    });
  });

  group('#getWords', () {
    test('null', () async {
      when(() => storage.read<List<String>?>(any())).thenAnswer((_) async => null);
      expect(await repository.getWords(), []);
    });

    test('topic', () async {
      when(() => storage.read<List<String>?>(any())).thenAnswer((_) async => ['a', 'b']);
      expect(await repository.getWords(), ['a', 'b']);
    });
    test('noun', () async {
      when(() => storage.read<List<String>?>(any())).thenAnswer((_) async => ['a', 'b']);
      expect(await repository.getWords(type: WordType.noun), ['a', 'b']);
    });
    test('adj', () async {
      when(() => storage.read<List<String>?>(any())).thenAnswer((_) async => ['a', 'b']);
      expect(await repository.getWords(type: WordType.adjective), ['a', 'b']);
    });
  });
}
