import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:turn2draw/config/http.dart';
import 'package:turn2draw/config/logger.dart';
import 'package:turn2draw/config/preferences_keys.dart';
import 'package:turn2draw/data/unimplemented_preferences.dart';

part './impl/http_sp_word_repository.dart';

enum WordType {
  adjective,
  noun,
  topic;

  /// returns a string which is sent to the server to identify the word type
  String getHttpKey() => switch (this) {
        WordType.topic => 'topic',
        WordType.noun => 'noun',
        WordType.adjective => 'adj',
      };

  /// returns the key of the word list
  String getPreferenceKey() => switch (this) {
        WordType.adjective => pAdjList,
        WordType.noun => pNounList,
        WordType.topic => pTopicList,
      };

  /// returns a string that represents the key
  /// where the e-tag for the type is stored
  String getPreferenceETagKey() => switch (this) {
        WordType.adjective => pAdjListETag,
        WordType.noun => pNounListETag,
        WordType.topic => pTopicListETag,
      };
}

abstract class WordRepository {
  /// fetches all known word types and stores them
  Future<void> fetchAllWords();

  /// sends a request to the server & stores the result
  Future<void> fetchWords({WordType type = WordType.topic});

  /// returns a list of words
  Future<List<String>> getWords({WordType type = WordType.topic});
}
