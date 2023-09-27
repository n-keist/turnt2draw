import 'package:equatable/equatable.dart';

class Player extends Equatable {

  const Player({
    this.playerId = '',
    this.playerSession = '',
    this.playerDisplayname = '',
  });

  factory Player.parseJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['player_id'],
      playerSession: json['player_session'],
      playerDisplayname: json['player_displayname'],
    );
  }

  final String playerId;
  final String playerSession;
  final String playerDisplayname;

  @override
  List<Object?> get props => [playerId, playerSession, playerDisplayname];
}