import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/config/logger.dart';
import 'package:turn2draw/config/socket.dart';
import 'package:turn2draw/data/mapping/drawable_mapping.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'package:turn2draw/data/model/turn_info.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:turn2draw/ui/_state/common_effects/dialog_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/player_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/session_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/turn_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/drawable_effect.dart';
import 'package:turn2draw/ui/_state/session/events/init_event.dart';
import 'package:turn2draw/ui/screens/session/session.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    SessionService? sessionService,
    PlayerService? playerService,
  })  : sessionService = sessionService ?? RemoteSessionService(),
        playerService = playerService ?? LocalPlayerService(),
        super(SessionState()) {
    on<LocalSessionEvent>(_onLocalSessionEvent);
    on<SocketSessionEvent>(_onSessionSocketEvent);
    on<DrawableSessionEvent>(_onDrawableSessionEvent);
    on<InitSessionEvent>(_onInitSessionEvent);
  }

  final SessionService sessionService;
  final PlayerService playerService;

  void _onInitSessionEvent(InitSessionEvent event, Emitter<SessionState> emit) async {
    final player = await playerService.getCurrentPlayer();

    emit(
      state.copyWith(
        self: () => player,
      ),
    );
  }

  void _onLocalSessionEvent(LocalSessionEvent event, Emitter<SessionState> emit) async {
    switch (event.type) {
      case LocalSessionEventType.find:
        emit(await _joinSession(event.sessionId));
        break;
      case LocalSessionEventType.begin:
        emit(await _startSession(state.info.id));
        break;
      default:
        throw 'no local event type';
    }
  }

  void _onSessionSocketEvent(SocketSessionEvent event, Emitter<SessionState> emit) async {
    logger.d('SOCKET: "${event.event}" payload?: ${event.payload != null}');
    if (event.event == onConnect) {
      event.socket.emit(
        emitPlayerCheckIn,
        state.self.copyWith(playerSession: () => state.info.id).toJson(),
      );
      return;
    }

    if (event.event == onSessionPlayers) {
      if (event.payload == null) throw 'unexpected null payload on ${event.event}';
      final players = (event.payload!['players']).map<Player>((json) => Player.parseJson(json)).toList(growable: true);
      emit(
        state.copyWith(players: () => players),
      );
      return;
    }

    if (event.event == onSessionStateUpdate) {
      if (event.payload == null) throw 'unexpected null payload on ${event.event}';
      final info = SessionInfo.parseJson(event.payload!);
      emit(state.copyWith(info: () => info));
      return;
    }

    if (event.event == onSessionNextTurn) {
      if (event.payload == null) throw 'unexpected null payload on ${event.event}';
      final turnInfo = TurnInfo.json(event.payload!);
      emit(
        state.copyWith(
          turnInfo: () => turnInfo,
          effect: () => turnInfo.turnPlayer == state.self.playerId ? MyTurnEffect() : NotMyTurnEffect(),
        ),
      );
      return;
    }

    if (event.event == onSessionFinished) {
      emit(state.copyWith(effect: () => EndSessionEffect()));
      return;
    }

    if (event.event == onSessionDrawables) {
      if (event.payload == null) throw 'unexpected null payload on ${event.event}';
      final drawable = mapJsonToDrawable(event.payload!);
      emit(
        state.copyWith(effect: () => UpdateDrawableEffect(drawable: drawable)),
      );
      return;
    }
    if (event.event == onSessionState) {
      if (event.payload == null) throw 'unexpected null payload on ${event.event}';
      final sessionInfo = SessionInfo.parseJson(event.payload!['info']);
      final players = (event.payload!['players']).map<Player>((json) => Player.parseJson(json)).toList(growable: true);

      emit(
        state.copyWith(
          info: () => sessionInfo,
          players: () => players,
        ),
      );
      return;
    }
  }

  void _onDrawableSessionEvent(DrawableSessionEvent event, Emitter<SessionState> emit) async {
    switch (event.eventType) {
      case DrawableEventType.create:
      case DrawableEventType.update:
        event.socket.emit(
          emitSessionDrawing,
          {
            'sessionId': state.info.id,
            'drawable': mapDrawableToJson(event.drawable),
          },
        );
        break;
      case DrawableEventType.commit:
        event.socket.emit(emitSessionCommitDrawing, mapDrawableToJson(event.drawable));
        break;
      default:
        throw 'event type not implemented';
    }
  }

  Future<SessionState> _joinSession(String sessionId) async {
    final session = await sessionService.findSession(sessionId);
    if (session == null) {
      return state.copyWith(
        effect: () => NotFoundSessionEffect(),
      );
    }
    return state.copyWith(
      info: () => session,
    );
  }

  Future<SessionState> _startSession(String sessionId) async {
    final result = await sessionService.beginSession(sessionId);
    if (result == null) return state.copyWith();
    return switch (result) {
      'NOT_ENOUGH_PLAYERS' => state.copyWith(
          effect: () => DialogEffect(
            title: 'WAIT!',
            body: 'There\'s a minimum of 2 (two) players required to play!',
          ),
        ),
      _ => throw 'unknown error type $result',
    };
  }

  @override
  void onChange(Change<SessionState> change) {
    logger.d('SESS-EFF: ${change.currentState.effect.runtimeType} -> ${change.nextState.effect.runtimeType}');
    super.onChange(change);
  }
}
