import 'package:turn2draw/config/logger.dart';

enum GameState {
  waiting,
  playing,
  done;

  const GameState();

  static GameState plain(String? plain) {
    return switch (plain) {
      'waiting' => GameState.waiting,
      'drawing' => GameState.playing,
      'done' => GameState.done,
      _ => GameState.waiting,
    };
  }
}

class SessionInfo {
  SessionInfo({
    this.id = '',
    this.code = '',
    DateTime? start,
    this.state = GameState.waiting,
    this.word,
    this.maxPlayers = 0,
    this.roundCount = 0,
    this.turnDuration = 0,
    this.owner = '',
    DateTime? end,
  })  : start = start ?? DateTime(2023),
        end = end ?? DateTime(2023);

  factory SessionInfo.parseJson(Map<String, dynamic> json) {
    logger.d(json.toString());
    return SessionInfo(
      id: json['session_id'],
      code: json['session_code'],
      start: DateTime.tryParse(json['session_start'] ?? ''),
      state: GameState.plain(json['session_state']),
      word: json['session_word'],
      maxPlayers: json['session_max_players'],
      roundCount: json['session_round_count'],
      turnDuration: json['session_turn_duration'],
      owner: json['session_owner'],
      end: DateTime.tryParse(json['session_end'] ?? ''),
    );
  }

  final String id;
  final String code;
  final DateTime start;
  final GameState state;
  final String? word;
  final int maxPlayers;
  final int roundCount;
  final int turnDuration;
  final String owner;
  final DateTime end;
}
