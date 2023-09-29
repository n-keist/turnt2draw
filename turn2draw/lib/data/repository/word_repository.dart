import 'dart:convert';
import 'dart:developer';

import 'package:turn2draw/config/http.dart';
import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/storage/impl/in_memory_local_storage.dart';
import 'package:turn2draw/storage/local_storage.dart';

import 'package:http/http.dart' as http;

enum WordType {
  adjective,
  noun,
  topic;
}

class WordRepository {
  WordRepository({LocalStorage? storage, http.Client? client})
      : storage = storage ?? InMemoryLocalStorage(),
        client = client ?? http.Client();

  final LocalStorage storage;
  final http.Client client;

  Future<void> fetchAllWords() async {
    for (final type in WordType.values) {
      await fetchWords(type: type);
    }
  }

  Future<void> fetchWords({WordType type = WordType.topic}) async {
    try {
      final eTagKey = switch (type) {
        WordType.topic => pTopicListETag,
        WordType.noun => pNounListETag,
        WordType.adjective => pAdjListETag,
      };

      final eTag = await storage.read<String?>(eTagKey);

      final response = await client.get(
        Uri.parse(httpBaseUrl).replace(
          path: '/api/words/word',
          queryParameters: {
            'type': switch (type) {
              WordType.topic => 'topic',
              WordType.noun => 'noun',
              WordType.adjective => 'adj',
            },
          },
        ),
        headers: {
          if (eTag != null) 'If-None-Match': eTag,
        },
      );

      if (response.statusCode != 200) return;
      final json = jsonDecode(response.body);
      final List<String> words = json.map<String>((word) => '$word').toList(growable: false);
      await storage.write<List<String>>(
        switch (type) {
          WordType.topic => pTopicList,
          WordType.noun => pNounList,
          WordType.adjective => pAdjList,
        },
        words,
      );
      final responsETagValue = response.headers['E-Tag'];
      if (responsETagValue != null) {
        await storage.write<String>(eTagKey, responsETagValue);
      }
    } catch (e) {
      log('could not read words', error: e);
    }
  }

  Future<List<String>> getWords({WordType type = WordType.topic}) async {
    final words = await storage.read<List<String>?>(
      switch (type) {
        WordType.adjective => pAdjList,
        WordType.noun => pNounList,
        WordType.topic => pTopicList,
      },
    );
    if (words != null) return words;
    return [];
  }
}
