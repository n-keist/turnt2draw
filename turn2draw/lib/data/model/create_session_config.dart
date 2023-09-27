import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:turn2draw/config/dev.dart';

class CreateSessionConfig extends Equatable {
  const CreateSessionConfig({
    this.word,
    this.maxPlayers = 0,
    this.roundCount = 0,
    this.turnDuration = 0,
    this.sessionOwner = '',
    this.ownerDisplayname = '',
  });

  final String? word;
  final int maxPlayers;
  final int roundCount;
  final int turnDuration;
  final String sessionOwner;
  final String ownerDisplayname;

  Map<String, dynamic> toJson() => {
        if (kDebugMode) 'id': devSessionId,
        'word': word,
        'maxPlayers': maxPlayers,
        'roundCount': roundCount,
        'turnDuration': turnDuration,
        'owner': sessionOwner,
        'ownerDisplayname': ownerDisplayname,
      };

  @override
  List<Object?> get props => [
        word,
        maxPlayers,
        roundCount,
        turnDuration,
        sessionOwner,
        ownerDisplayname
      ];
}
