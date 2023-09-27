part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.word,
    this.roundCount = 5,
    this.turnDuration = 30,
    this.maxPlayers = 5,
    this.effect,
  });

  HomeState copyWith({
    String? Function()? word,
    int Function()? roundCount,
    int Function()? turnDuration,
    int Function()? maxPlayers,
    Effect? Function()? effect,
  }) {
    return HomeState(
      word: word != null ? word.call() : this.word,
      roundCount: roundCount != null ? roundCount.call() : this.roundCount,
      turnDuration:
          turnDuration != null ? turnDuration.call() : this.turnDuration,
      maxPlayers: maxPlayers != null ? maxPlayers.call() : this.maxPlayers,
      effect: effect != null ? effect.call() : this.effect,
    );
  }

  final String? word;
  final int roundCount;
  final int turnDuration;
  final int maxPlayers;

  final Effect? effect;

  @override
  List<Object?> get props =>
      [word, roundCount, turnDuration, maxPlayers, effect];
}
