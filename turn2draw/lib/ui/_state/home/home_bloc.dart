import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/config/logger.dart';
import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/data/service/impl/local_player_service.dart';
import 'package:turn2draw/data/service/impl/remote_session_service.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:turn2draw/ui/_state/effect.dart';
import 'package:turn2draw/ui/_state/home/effects/session_effect.dart';

import 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    WordRepository? wordRepository,
    PlayerService? playerService,
    SessionService? sessionService,
  })  : wordRepository = wordRepository ?? WordRepository(),
        playerService = playerService ?? LocalPlayerService(),
        sessionService = sessionService ?? RemoteSessionService(),
        super(const HomeState()) {
    on<HomeInitEvent>(_onHomeInitEvent);
    on<ChangeCountOnSubjectEvent>(_onChangeCountOnSubjectEvent);
    on<CreateSessionEvent>(_onCreateSessionEvent);
    on<JoinSessionEvent>(_onJoinSessionEvent);
    on<ClearWordEvent>(_onClearWordEvent);
    on<PickNewWordEvent>(_onPickNewWordEvent);
  }

  final WordRepository wordRepository;
  final PlayerService playerService;
  final SessionService sessionService;

  final random = Random();

  void _onHomeInitEvent(HomeInitEvent event, Emitter<HomeState> emit) async {
    for (var type in WordType.values) {
      await wordRepository.fetchWords(type: type);
    }
    final adjectives = await wordRepository.getWords(type: WordType.adjective);
    final nouns = await wordRepository.getWords(type: WordType.noun);

    final generatedName = [
      adjectives.elementAt(random.nextInt(adjectives.length - 1)),
      nouns.elementAt(random.nextInt(nouns.length - 1)),
    ].join('_');

    await playerService.createPlayerIfNotExists(generatedName);
  }

  void _onChangeCountOnSubjectEvent(
      ChangeCountOnSubjectEvent event, Emitter<HomeState> emit) async {
    switch (event.subject) {
      case CountSubject.playerCount:
        emit(
          state.copyWith(
            maxPlayers: () => switch (event.type) {
              CountEventType.add => state.maxPlayers >= 99
                  ? state.maxPlayers
                  : state.maxPlayers + 1,
              CountEventType.remove =>
                state.maxPlayers <= 2 ? state.maxPlayers : state.maxPlayers - 1,
            },
          ),
        );
        break;
      case CountSubject.roundCount:
        emit(
          state.copyWith(
            roundCount: () => switch (event.type) {
              CountEventType.add => state.roundCount >= 99
                  ? state.roundCount
                  : state.roundCount + 1,
              CountEventType.remove =>
                state.roundCount <= 2 ? state.roundCount : state.roundCount - 1,
            },
          ),
        );
        break;
      case CountSubject.turnDuration:
        emit(
          state.copyWith(
            turnDuration: () => switch (event.type) {
              CountEventType.add => state.turnDuration >= 120
                  ? state.turnDuration
                  : state.turnDuration + 5,
              CountEventType.remove => state.turnDuration <= 5
                  ? state.turnDuration
                  : state.turnDuration - 5,
            },
          ),
        );
        break;
      default:
        throw UnimplementedError('subject type not implemented');
    }
  }

  void _onClearWordEvent(ClearWordEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(word: () => null));
  }

  void _onPickNewWordEvent(
      PickNewWordEvent event, Emitter<HomeState> emit) async {
    final topics = await wordRepository.getWords();
    final topic = switch (topics.length) {
      > 1 => topics.elementAt(random.nextInt(topics.length - 1)),
      _ => topics[0],
    };
    emit(state.copyWith(word: () => topic));
  }

  void _onCreateSessionEvent(
      CreateSessionEvent event, Emitter<HomeState> emit) async {
    final playerId = await playerService.getCurrentPlayerId();
    if (playerId == null) return;
    final config = CreateSessionConfig(
      maxPlayers: state.maxPlayers,
      roundCount: state.roundCount,
      turnDuration: state.turnDuration,
      sessionOwner: playerId,
      ownerDisplayname: await playerService.getCurrentPlayerName() ?? '',
      word: state.word,
    );

    final session = await sessionService.startSession(config);
    if (session == null) return;
    emit(
      state.copyWith(
        effect: () =>
            SessionEffect(type: SessionEffectType.created, sessionId: session),
      ),
    );
  }

  void _onJoinSessionEvent(
      JoinSessionEvent event, Emitter<HomeState> emit) async {
    final playerId = await playerService.getCurrentPlayerId();
    final playerName = await playerService.getCurrentPlayerName();
    final result = await sessionService.joinSession(
        event.sessionId, playerId!, playerName!, null);
    logger.d('JOIN: $result');
    if (result) {
      emit(
        state.copyWith(
          effect: () => SessionEffect(
              type: SessionEffectType.joined, sessionId: event.sessionId),
        ),
      );
    }
  }
}
