import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turn2draw/config/dev.dart';
import 'package:turn2draw/data/model/create_session_config.dart';

void main() {
  test('toJson works', () {
    const config = CreateSessionConfig(
      word: 'some-word',
      maxPlayers: 10,
      roundCount: 10,
      turnDuration: 200,
      sessionOwner: 'some-owner',
      ownerDisplayname: 'some-owner-name',
    );
    expect(
      config.toJson(),
      {
        'word': 'some-word',
        'maxPlayers': 10,
        'roundCount': 10,
        'turnDuration': 200,
        'owner': 'some-owner',
        'ownerDisplayname': 'some-owner-name',
        if (kDebugMode) 'id': devSessionId,
      },
    );
  });
}
