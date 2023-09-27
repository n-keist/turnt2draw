import 'package:equatable/equatable.dart';
import 'package:turn2draw/data/extension/map_extension.dart';

class TurnInfo extends Equatable {
  const TurnInfo({
    this.turnId = '',
    this.turnSession = '',
    this.turnPlayer = '',
    this.turnOverall = 0,
    this.turnSkipped,
    this.turnEnded,
  });

  factory TurnInfo.json(Map<String, dynamic> json) {
    return TurnInfo(
      turnId: json['turn_id'],
      turnSession: json['turn_session'],
      turnPlayer: json['turn_player'],
      turnOverall: json['turn_overall'],
      turnSkipped: json['turn_skipped'],
      turnEnded: json.toOptionalDateTime('turn_ended'),
    );
  }

  final String turnId;
  final String turnSession;
  final String turnPlayer;
  final int turnOverall;
  final bool? turnSkipped;
  final DateTime? turnEnded;

  @override
  List<Object?> get props => [turnId, turnSession, turnPlayer, turnOverall, turnSkipped, turnEnded];
}
