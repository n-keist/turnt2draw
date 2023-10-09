import 'package:equatable/equatable.dart';
import 'package:turn2draw/data/extension/fn_extension.dart';

class Player extends Equatable {
  const Player({
    this.playerId = '',
    this.playerSession = '',
    this.playerDisplayname = '',
    this.playerIcon = '',
  });

  factory Player.parseJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['player_id'],
      playerSession: json['player_session'],
      playerDisplayname: json['player_displayname'],
      playerIcon: json['player_icon'],
    );
  }

  Player copyWith(
      {String Function()? playerId,
      String Function()? playerSession,
      String Function()? playerDisplayname,
      String Function()? playerIcon}) {
    return Player(
      playerId: playerId.callOrElse<String>(orElse: this.playerId),
      playerSession: playerSession.callOrElse<String>(orElse: this.playerSession),
      playerDisplayname: playerDisplayname.callOrElse<String>(orElse: this.playerDisplayname),
      playerIcon: playerIcon.callOrElse<String>(orElse: this.playerIcon),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, String>{
      'player_id': playerId,
      'player_session': playerSession,
      'player_displayname': playerDisplayname,
      'player_icon': playerIcon,
    };
  }

  final String playerId;
  final String playerSession;
  final String playerDisplayname;
  final String playerIcon;

  @override
  List<Object?> get props => [playerId, playerSession, playerDisplayname, playerIcon];
}
