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
        when(() => repository.fetchWords(type: type)).thenAnswer((_) => Future.value(null));
      }
      when(() => repository.getWords(type: WordType.adjective)).thenAnswer((_) async => ['green', 'blue']);
      when(() => repository.getWords(type: WordType.noun)).thenAnswer((_) async => ['hat', 'glass']);
      when(() => playerService.createPlayerIfNotExists(any())).thenAnswer((_) async => 'some-id');
    },
    verify: (bloc) {
      verify(() => playerService.createPlayerIfNotExists(any())).called(1);
    },
  );

  group('ChangeCountOnSubjectEvent', () {
    group('playerCount', () {
      blocTest(
        'remove',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          maxPlayers: 3,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.playerCount, type: CountEventType.remove),
        ),
        expect: () => [
          const TypeMatcher<HomeState>().having((s) => s.maxPlayers, 'max players', 2),
        ],
      );
      blocTest(
        'add',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          maxPlayers: 3,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.playerCount, type: CountEventType.add),
        ),
        expect: () => [
          const TypeMatcher<HomeState>().having((s) => s.maxPlayers, 'max players', 4),
        ],
      );
      blocTest(
        'min reached',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          maxPlayers: 2,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.playerCount, type: CountEventType.remove),
        ),
        verify: (b) => expect(b.state.maxPlayers, 2),
      );
      blocTest(
        'max reached',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          maxPlayers: 99,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.playerCount, type: CountEventType.add),
        ),
        verify: (b) => expect(b.state.maxPlayers, 99),
      );
    });

    group('roundCount', () {
      blocTest(
        'remove',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          roundCount: 3,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.roundCount, type: CountEventType.remove),
        ),
        expect: () => [
          const TypeMatcher<HomeState>().having((s) => s.roundCount, 'round count', 2),
        ],
      );
      blocTest(
        'add',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          roundCount: 3,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.roundCount, type: CountEventType.add),
        ),
        expect: () => [
          const TypeMatcher<HomeState>().having((s) => s.roundCount, 'round count', 4),
        ],
      );
      blocTest(
        'min reached',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          roundCount: 2,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.roundCount, type: CountEventType.remove),
        ),
        verify: (b) => expect(b.state.roundCount, 2),
      );
      blocTest(
        'max reached',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          roundCount: 99,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.roundCount, type: CountEventType.add),
        ),
        verify: (b) => expect(b.state.roundCount, 99),
      );
    });

    group('turnDuration', () {
      blocTest(
        'remove',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          turnDuration: 10,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.turnDuration, type: CountEventType.remove),
        ),
        expect: () => [
          const TypeMatcher<HomeState>().having((s) => s.turnDuration, 'turn duration', 5),
        ],
      );
      blocTest(
        'add',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          turnDuration: 5,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.turnDuration, type: CountEventType.add),
        ),
        expect: () => [
          const TypeMatcher<HomeState>().having((s) => s.turnDuration, 'round count', 10),
        ],
      );
      blocTest(
        'min reached',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          turnDuration: 5,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.turnDuration, type: CountEventType.remove),
        ),
        verify: (b) => expect(b.state.turnDuration, 5),
      );
      blocTest(
        'max reached',
        build: () => HomeBloc(),
        seed: () => const HomeState(
          turnDuration: 120,
        ),
        act: (bloc) => bloc.add(
          ChangeCountOnSubjectEvent(subject: CountSubject.turnDuration, type: CountEventType.add),
        ),
        verify: (b) => expect(b.state.turnDuration, 120),
      );
    });
  });

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
      when(() => playerService.getCurrentPlayerId()).thenAnswer((_) async => config.sessionOwner);
      when(() => playerService.getCurrentPlayerName()).thenAnswer((_) async => config.ownerDisplayname);

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
      when(() => playerService.getCurrentPlayerId()).thenAnswer((_) async => 'some-id');
      when(() => playerService.getCurrentPlayerName()).thenAnswer((_) async => 'some-name');

      when(() => sessionService.joinSession('some-id', 'some-id', 'some-name', null)).thenAnswer((_) async => true);
    },
    act: (b) => b.add(JoinSessionEvent(sessionId: 'some-id')),
    verify: (b) {
      expect(b.state.effect, isNotNull);
      expect(b.state.effect, isA<SessionEffect>());
    },
  );
}
