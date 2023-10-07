import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/data/extension/fn_extension.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:turn2draw/ui/_state/effect.dart';
import 'package:turn2draw/ui/_state/common_effects/dialog_effect.dart';
import 'package:turn2draw/ui/_state/home/effects/session_effect.dart';

import 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    WordRepository? wordRepository,
    PlayerService? playerService,
    SessionService? sessionService,
  })  : wordRepository = wordRepository ?? HttpSharedPreferencesWordRepository(),
        playerService = playerService ?? LocalPlayerService(),
        sessionService = sessionService ?? RemoteSessionService(),
        super(const HomeState()) {
    on<HomeInitEvent>(_onHomeInitEvent);
    on<CreateSessionEvent>(_onCreateSessionEvent);
    on<JoinSessionEvent>(_onJoinSessionEvent);
    on<PlayerEvent>(_onPlayerEvent);
  }

  final WordRepository wordRepository;
  final PlayerService playerService;
  final SessionService sessionService;

  final random = Random();

  void _onHomeInitEvent(HomeInitEvent event, Emitter<HomeState> emit) async {
    await wordRepository.fetchAllWords();

    final generatedName = await _generateRandomName();

    final (playerId, playerName) = await playerService.createPlayerIfNotExists(generatedName);
    emit(
      state.copyWith(
        self: () => Player(playerId: playerId, playerDisplayname: playerName),
      ),
    );
  }

  void _onPlayerEvent(PlayerEvent event, Emitter<HomeState> emit) async {
    if (event.type == PlayerEventType.regenerateUsername) {
      final name = await _generateRandomName();
      await playerService.setCurrentPlayerName(name);
      final playerId = await playerService.getCurrentPlayerId();
      final playerName = await playerService.getCurrentPlayerName();
      emit(
        state.copyWith(
          self: () => Player(
            playerId: playerId!,
            playerDisplayname: playerName!,
          ),
        ),
      );
      return;
    }
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
      return emit(
        state.copyWith(
          effect: () => DialogEffect(
            title: 'My bad!',
            body: 'Unable to start a session, try again',
          ),
        ),
      );
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

    // If no session code, find a random available game
    if (event.sessionCode == null) {
      final result = await sessionService.joinRandomSession(playerId!, playerName!);

      /// no available game found
      if (result == null) {
        return emit(
          state.copyWith(
            effect: () => DialogEffect(
              title: 'Argghh! >:(',
              body: 'There doesn\'t seem to be an open game available',
            ),
          ),
        );
      }
      emit(
        state.copyWith(
          effect: () => SessionEffect(type: SessionEffectType.joined, sessionId: result),
        ),
      );
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

  Future<String> _generateRandomName() async {
    final adjectives = await wordRepository.getWords(type: WordType.adjective);

    final nouns = await wordRepository.getWords(type: WordType.noun);

    final generatedName = [
      adjectives.elementAt(random.nextInt(adjectives.length - 1)),
      nouns.elementAt(random.nextInt(nouns.length - 1)),
    ].join('_');
    return generatedName;
  }
}
