part of 'home_bloc.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    Player? self,
    this.effect,
  }) : self = self ?? const Player();

  HomeState copyWith({
    Player Function()? self,
    Effect? Function()? effect,
  }) {
    return HomeState(
      self: self.callOrElse<Player>(orElse: this.self),
      effect: effect.callOrElse<Effect?>(orElse: this.effect),
    );
  }

  final Player self;
  final Effect? effect;

  @override
  List<Object?> get props => [self, effect];
}
