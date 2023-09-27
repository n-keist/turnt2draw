import 'dart:developer';

import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/storage/impl/in_memory_local_storage.dart';
import 'package:turn2draw/storage/local_storage.dart';
import 'package:uno/uno.dart';

enum WordType {
  adjective,
  noun,
  topic;
}

class WordRepository {
  WordRepository({LocalStorage? storage, Uno? uno})
      : storage = storage ?? InMemoryLocalStorage(),
        uno = uno ?? Uno();

  final LocalStorage storage;
  final Uno uno;

  Future<void> fetchWords({WordType type = WordType.topic}) async {
    try {
      final eTag = await storage.read<String?>(
        switch (type) {
          WordType.topic => pTopicListETag,
          WordType.noun => pNounListETag,
          WordType.adjective => pAdjListETag,
        },
      );

      final response = await uno.get(
        '/api/words/word',
        headers: {
          if (eTag != null) 'If-None-Match': eTag,
        },
        params: {
          'type': switch (type) {
            WordType.topic => 'topic',
            WordType.noun => 'noun',
            WordType.adjective => 'adj',
          },
        },
      );

      if (response.status != 200) return;
      final List<String> words = response.data.map<String>((word) => '$word').toList(growable: false);
      await storage.write<List<String>>(
        switch (type) {
          WordType.topic => pTopicList,
          WordType.noun => pNounList,
          WordType.adjective => pAdjList,
        },
        words,
      );
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
