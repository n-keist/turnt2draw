import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:turn2draw/config/dev.dart';
import 'package:turn2draw/data/extension/fn_extension.dart';

class CreateSessionConfig extends Equatable {
  const CreateSessionConfig({
    this.word,
    this.maxPlayers = 0,
    this.roundCount = 0,
    this.turnDuration = 0,
    this.sessionOwner = '',
  });

  factory CreateSessionConfig.empty() => const CreateSessionConfig(
        maxPlayers: 5,
        roundCount: 10,
        turnDuration: 60,
      );

  CreateSessionConfig copyWith({
    String? Function()? word,
    int Function()? maxPlayers,
    int Function()? roundCount,
    int Function()? turnDuration,
    String Function()? sessionOwner,
  }) {
    return CreateSessionConfig(
      word: word.callOrElse<String?>(orElse: this.word),
      maxPlayers: maxPlayers.callOrElse<int>(orElse: this.maxPlayers),
      roundCount: roundCount.callOrElse<int>(orElse: this.roundCount),
      turnDuration: turnDuration.callOrElse<int>(orElse: this.turnDuration),
      sessionOwner: sessionOwner.callOrElse<String>(orElse: this.sessionOwner),
    );
  }

  final String? word;
  final int maxPlayers;
  final int roundCount;
  final int turnDuration;
  final String sessionOwner;

  Map<String, dynamic> toJson() => {
        if (kDebugMode) 'id': devSessionId,
        'word': word,
        'maxPlayers': maxPlayers,
        'roundCount': roundCount,
        'turnDuration': turnDuration,
        'owner': sessionOwner,
      };

  @override
  List<Object?> get props => [word, maxPlayers, roundCount, turnDuration, sessionOwner];
}
