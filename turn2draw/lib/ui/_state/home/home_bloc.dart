import 'dart:math';

import 'package:emojis/emoji.dart';
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
import 'package:turn2draw/ui/_state/session/effects/session_effect.dart';

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
    try {
      await wordRepository.fetchAllWords();

      final generatedName = await _generateRandomName();

      final generatedIcon = _generateRandomIcon();

      final (playerId, playerName) = await playerService.createPlayerIfNotExists(generatedName);
      await playerService.setCurrentPlayerIcon(generatedIcon.shortName);
      emit(
        state.copyWith(
          self: () => Player(playerId: playerId, playerDisplayname: playerName, playerIcon: generatedIcon.char),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          effect: () => DialogEffect(
            title: 'thats... awkward',
            body: 'Something went wrong during initial setup, please retry',
            dismissable: false,
          ),
        ),
      );
    }
  }

  void _onPlayerEvent(PlayerEvent event, Emitter<HomeState> emit) async {
    if (event.type == PlayerEventType.regenerateUsername) {
      final name = await _generateRandomName();
      await playerService.setCurrentPlayerName(name);
      final player = await playerService.getCurrentPlayer();
      emit(
        state.copyWith(
          self: () => player,
        ),
      );
      return;
    }
    if (event.type == PlayerEventType.regenerateIcon) {
      final icon = _generateRandomIcon();
      await playerService.setCurrentPlayerIcon(icon.shortName);
      final player = await playerService.getCurrentPlayer();
      emit(
        state.copyWith(self: () => player),
      );
      return;
    }
  }

  void _onCreateSessionEvent(CreateSessionEvent event, Emitter<HomeState> emit) async {
    final playerId = await playerService.getCurrentPlayerId();

    if (playerId == null) return;

    final config = event.config.copyWith(
      sessionOwner: () => playerId,
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
    final player = await playerService.getCurrentPlayer();

    // If no session code, find a random available game
    if (event.sessionCode == null) {
      final result = await sessionService.joinRandomSession(player);

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

    final session = await sessionService.findSessionByCode(event.sessionCode!);
    if (session == null) {
      return emit(
        state.copyWith(
          effect: () => NotFoundSessionEffect(), // TODO
        ),
      );
    }

    final result = await sessionService.joinSession(
      player.copyWith(playerSession: () => session.id),
    );
    if (result) {
      emit(
        state.copyWith(
          effect: () => SessionEffect(type: SessionEffectType.joined, sessionId: session.id),
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

  Emoji _generateRandomIcon() {
    final emojis = Emoji.byGroup(EmojiGroup.animalsNature).toList() + Emoji.byGroup(EmojiGroup.smileysEmotion).toList();

    return emojis.elementAt(Random().nextInt(emojis.length - 1));
  }
}
