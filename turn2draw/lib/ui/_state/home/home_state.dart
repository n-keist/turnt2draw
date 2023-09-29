part of 'home_bloc.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    this.word,
    this.roundCount = 5,
    this.turnDuration = 30,
    this.maxPlayers = 5,
    Player? self,
    this.effect,
  }) : self = self ?? const Player();

  HomeState copyWith({
    String? Function()? word,
    int Function()? roundCount,
    int Function()? turnDuration,
    int Function()? maxPlayers,
    Player Function()? self,
    Effect? Function()? effect,
  }) {
    return HomeState(
      word: word.callOrElse<String?>(orElse: this.word),
      roundCount: roundCount.callOrElse<int>(orElse: this.roundCount),
      turnDuration: turnDuration.callOrElse<int>(orElse: this.turnDuration),
      maxPlayers: maxPlayers.callOrElse<int>(orElse: this.maxPlayers),
      self: self.callOrElse<Player>(orElse: this.self),
      effect: effect.callOrElse<Effect?>(orElse: this.effect),
    );
  }

  final String? word;
  final int roundCount;
  final int turnDuration;
  final int maxPlayers;

  final Player self;
  final Effect? effect;

  @override
  List<Object?> get props => [word, roundCount, turnDuration, maxPlayers, self, effect];
}
