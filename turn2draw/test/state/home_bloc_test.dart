import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/model/player.dart';
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
      when(() => repository.fetchAllWords()).thenAnswer((_) async => false);
      when(() => repository.getWords(type: WordType.adjective)).thenAnswer((_) async => ['green', 'blue']);
      when(() => repository.getWords(type: WordType.noun)).thenAnswer((_) async => ['hat', 'glass']);
      when(() => playerService.createPlayerIfNotExists(any())).thenAnswer((_) async => ('some-id', 'some-name'));
    },
    verify: (bloc) {
      verify(() => playerService.createPlayerIfNotExists(any())).called(1);
    },
  );

  blocTest(
    'CreateSessionEvent',
    build: () => HomeBloc(
      playerService: playerService,
      sessionService: sessionService,
    ),
    setUp: () {
      const config = CreateSessionConfig(
        sessionOwner: 'player-id',
      );
      when(() => playerService.getCurrentPlayerId()).thenAnswer((_) async => config.sessionOwner);

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

      when(() => playerService.getCurrentPlayer()).thenAnswer((_) async => const Player());

      when(() => sessionService.joinSession(const Player())).thenAnswer((_) async => true);
    },
    act: (b) => b.add(JoinSessionEvent(sessionCode: 'some-id')),
    verify: (b) {
      expect(b.state.effect, isNotNull);
      expect(b.state.effect, isA<SessionEffect>());
    },
  );
}
