import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/data/extension/fn_extension.dart';
import 'package:turn2draw/data/model/player.dart';
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
    on<CreateSessionEvent>(_onCreateSessionEvent);
    on<JoinSessionEvent>(_onJoinSessionEvent);
  }

  final WordRepository wordRepository;
  final PlayerService playerService;
  final SessionService sessionService;

  final random = Random();

  void _onHomeInitEvent(HomeInitEvent event, Emitter<HomeState> emit) async {
    await wordRepository.fetchAllWords();
    final adjectives = await wordRepository.getWords(type: WordType.adjective);
    final nouns = await wordRepository.getWords(type: WordType.noun);

    final generatedName = [
      adjectives.elementAt(random.nextInt(adjectives.length - 1)),
      nouns.elementAt(random.nextInt(nouns.length - 1)),
    ].join('_');

    final (playerId, playerName) = await playerService.createPlayerIfNotExists(generatedName);
    emit(
      state.copyWith(
        self: () => Player(playerId: playerId, playerDisplayname: playerName),
      ),
    );
  }

  void _onCreateSessionEvent(CreateSessionEvent event, Emitter<HomeState> emit) async {
    final playerId = await playerService.getCurrentPlayerId();
    final playerName = await playerService.getCurrentPlayerName();

    if (playerId == null || playerName == null) return;

    final config = event.config.copyWith(
      sessionOwner: () => playerId,
      ownerDisplayname: () => playerName,
    );

    final session = await sessionService.startSession(config);
    if (session == null) {
      // TODO: emit effect that confirms an error
      return;
    }

    emit(
      state.copyWith(
        effect: () => SessionEffect(type: SessionEffectType.created, sessionId: session),
      ),
    );
  }

  void _onJoinSessionEvent(JoinSessionEvent event, Emitter<HomeState> emit) async {
    final playerId = await playerService.getCurrentPlayerId();
    final playerName = await playerService.getCurrentPlayerName();
    if (event.sessionCode == null) {
      // Find (random) available game
      return;
    }
    final result = await sessionService.joinSession(event.sessionCode!, playerId!, playerName!, null);
    if (result) {
      emit(
        state.copyWith(
          effect: () => SessionEffect(type: SessionEffectType.joined, sessionId: event.sessionCode!),
        ),
      );
    }
  }
}
