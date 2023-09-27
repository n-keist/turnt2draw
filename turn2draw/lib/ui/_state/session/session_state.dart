import 'package:equatable/equatable.dart';
import 'package:turn2draw/data/extension/fn_extension.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'package:turn2draw/data/model/turn_info.dart';
import 'package:turn2draw/ui/_state/effect.dart';

class SessionState extends Equatable {
  SessionState({
    SessionInfo? info,
    TurnInfo? turnInfo,
    Player? self,
    this.players = const [],
    this.effect,
  })  : info = info ?? SessionInfo(),
        turnInfo = turnInfo ?? const TurnInfo(),
        self = self ?? const Player();

  SessionState copyWith({
    SessionInfo? Function()? info,
    TurnInfo? Function()? turnInfo,
    Player Function()? self,
    List<Player> Function()? players,
    Effect? Function()? effect,
  }) {
    return SessionState(
      info: info.callOrElse<SessionInfo>(orElse: this.info),
      turnInfo: turnInfo.callOrElse<TurnInfo>(orElse: this.turnInfo),
      self: self.callOrElse<Player>(orElse: this.self),
      players: players.callOrElse<List<Player>>(orElse: this.players),
      effect: effect.callOrElse<Effect?>(orElse: this.effect),
    );
  }

  final SessionInfo info;
  final TurnInfo turnInfo;
  final Player self;
  final List<Player> players;
  final Effect? effect;

  @override
  List<Object?> get props => [info, turnInfo, self, players, effect];
}
