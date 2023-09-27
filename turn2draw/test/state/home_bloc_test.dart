import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/ui/_state/home/effects/session_effect.dart';
import 'package:turn2draw/ui/_state/home/home_event.dart';
import 'package:turn2draw/ui/screens/home/home.dart';

import '../mock/player_service_mock.dart';
import '../mock/session_service_mock.dart';
import '../mock/word_repository_mock.dart';

void main() {
  final repository = MockWordRepository();
  final playerService = MockPlayerService();
  final sessionService = MockSessionService();

  blocTest(
    'HomeInitEvent',
    build: () => HomeBloc(
      wordRepository: repository,
      playerService: playerService,
      sessionService: sessionService,
    ),
    act: (bloc) => bloc.add(HomeInitEvent()),
    setUp: () {
      for (final type in WordType.values) {
        when(() => repository.fetchWords(type: type))
            .thenAnswer((_) => Future.value(null));
      }
      when(() => repository.getWords(type: WordType.adjective))
          .thenAnswer((_) async => ['green', 'blue']);
      when(() => repository.getWords(type: WordType.noun))
          .thenAnswer((_) async => ['hat', 'glass']);
      when(() => playerService.createPlayerIfNotExists(any()))
          .thenAnswer((_) async => 'some-id');
    },
    verify: (bloc) {
      verify(() => playerService.createPlayerIfNotExists(any())).called(1);
    },
  );

  blocTest(
    'ChangeCountOnSubjectEvent',
    build: () => HomeBloc(),
    act: (bloc) => bloc.add(
      ChangeCountOnSubjectEvent(
          subject: CountSubject.playerCount, type: CountEventType.add),
    ),
    expect: () => [
      const HomeState(maxPlayers: 6),
    ],
  );

  blocTest(
    'ClearWordEvent',
    build: () => HomeBloc(),
    seed: () => const HomeState(word: 'some-word'),
    act: (bloc) => bloc.add(ClearWordEvent()),
    expect: () => [const HomeState()],
  );

  blocTest(
    'PickNewWordEvent',
    build: () => HomeBloc(
      wordRepository: repository,
    ),
    setUp: () {
      when(() => repository.getWords()).thenAnswer((_) async => ['cool-topic']);
    },
    act: (bloc) => bloc.add(PickNewWordEvent()),
    expect: () => [
      const HomeState(word: 'cool-topic'),
    ],
  );

  blocTest(
    'CreateSessionEvent',
    build: () => HomeBloc(
      playerService: playerService,
      sessionService: sessionService,
    ),
    seed: () => const HomeState(
      maxPlayers: 5,
      roundCount: 5,
      turnDuration: 10,
      word: 'my-word',
    ),
    setUp: () {
      const config = CreateSessionConfig(
        sessionOwner: 'player-id',
        ownerDisplayname: 'player-name',
        maxPlayers: 5,
        roundCount: 5,
        turnDuration: 10,
        word: 'my-word',
      );
      when(() => playerService.getCurrentPlayerId())
          .thenAnswer((_) async => config.sessionOwner);
      when(() => playerService.getCurrentPlayerName())
          .thenAnswer((_) async => config.ownerDisplayname);

      when(() => sessionService.startSession(config)).thenAnswer(
        (_) async => 'session-id',
      );
    },
    act: (bloc) => bloc.add(CreateSessionEvent()),
    verify: (bloc) {
      expect(bloc.state.effect, isNotNull);
      expect(bloc.state.effect, isA<SessionEffect>());
    },
  );

  blocTest(
    'JoinSessionEvent',
    build: () => HomeBloc(
      playerService: playerService,
      sessionService: sessionService,
    ),
    setUp: () {
      when(() => playerService.getCurrentPlayerId())
          .thenAnswer((_) async => 'some-id');
      when(() => playerService.getCurrentPlayerName())
          .thenAnswer((_) async => 'some-name');

      when(() => sessionService.joinSession(
              'some-id', 'some-id', 'some-name', null))
          .thenAnswer((_) async => true);
    },
    act: (b) => b.add(JoinSessionEvent(sessionId: 'some-id')),
    verify: (b) {
      expect(b.state.effect, isNotNull);
      expect(b.state.effect, isA<SessionEffect>());
    },
  );
}
