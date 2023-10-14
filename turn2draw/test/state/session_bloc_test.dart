import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:turn2draw/config/socket.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'package:turn2draw/ui/_state/common_effects/dialog_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/drawable_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/session_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/turn_effect.dart';
import 'package:turn2draw/ui/_state/session/events/init_event.dart';
import 'package:turn2draw/ui/screens/session/session.dart';

import '../mock/player_service_mock.dart';
import '../mock/session_service_mock.dart';
import '../mock/socket_io_socket_mock.dart';

void main() {
  final playerService = MockPlayerService();
  final sessionService = MockSessionService();

  final socket = MockSocket();

  group('InitSessionEvent', () {
    blocTest(
      'player info is set',
      build: () => SessionBloc(
        playerService: playerService,
      ),
      setUp: () {
        when(() => playerService.getCurrentPlayer()).thenAnswer(
          (_) async => const Player(
            playerId: 'some-id',
            playerDisplayname: 'cool_name',
          ),
        );
      },
      act: (b) => b.add(InitSessionEvent()),
      expect: () => [
        const TypeMatcher<SessionState>()
            .having((state) => state.self.playerId, 'is player id', 'some-id')
            .having((state) => state.self.playerDisplayname, 'is player name', 'cool_name'),
      ],
    );
  });

  group('LocalSessionEvent', () {
    blocTest(
      'join: session not found',
      build: () => SessionBloc(
        sessionService: sessionService,
      ),
      setUp: () {
        when(() => sessionService.findSession(any())).thenAnswer((_) async => null);
      },
      act: (b) => b.add(
        LocalSessionEvent(type: LocalSessionEventType.find, sessionId: 'some-id'),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having(
          (state) => state.effect,
          'session not found',
          isA<NotFoundSessionEffect>(),
        ),
      ],
    );

    blocTest(
      'join: session found',
      build: () => SessionBloc(
        sessionService: sessionService,
      ),
      setUp: () {
        when(() => sessionService.findSession(any())).thenAnswer((_) async => SessionInfo(id: 'sess-id'));
      },
      act: (b) => b.add(
        LocalSessionEvent(type: LocalSessionEventType.find, sessionId: 'some-id'),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having(
          (state) => state.info.id,
          'session found',
          'sess-id',
        ),
      ],
    );

    blocTest(
      'start: not enough players',
      build: () => SessionBloc(
        sessionService: sessionService,
      ),
      setUp: () {
        when(() => sessionService.beginSession(any())).thenAnswer((_) async => 'NOT_ENOUGH_PLAYERS');
      },
      act: (b) => b.add(
        LocalSessionEvent(type: LocalSessionEventType.begin, sessionId: 'sess-id'),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having(
          (s) => s.effect,
          'sets dialog effect',
          isA<DialogEffect>(),
        ),
      ],
    );

    blocTest(
      'start: unknown error',
      build: () => SessionBloc(
        sessionService: sessionService,
      ),
      setUp: () {
        when(() => sessionService.beginSession(any())).thenAnswer((_) async => 'SOME_UNKNOWN_ERROR');
      },
      act: (b) => b.add(
        LocalSessionEvent(type: LocalSessionEventType.begin, sessionId: 'sess-id'),
      ),
      errors: () => [contains('SOME_UNKNOWN_ERROR')],
    );

    blocTest(
      'start: success',
      build: () => SessionBloc(
        sessionService: sessionService,
      ),
      setUp: () {
        when(() => sessionService.beginSession(any())).thenAnswer((_) async => null);
      },
      act: (b) => b.add(
        LocalSessionEvent(type: LocalSessionEventType.begin, sessionId: 'sess-id'),
      ),
    );
  });

  group('SocketSessionEvent', () {
    blocTest(
      'connect event',
      build: () => SessionBloc(),
      setUp: () {
        when(() => socket.emit(emitPlayerCheckIn, any())).thenReturn(null);
      },
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onConnect),
      ),
      verify: (b) {
        verify(() => socket.emit(any(), any()));
      },
    );

    blocTest(
      'players event: no payload',
      build: () => SessionBloc(),
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onSessionPlayers, payload: null),
      ),
      errors: () => [contains('null payload')],
    );

    blocTest(
      'players event: payload',
      build: () => SessionBloc(),
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onSessionPlayers, payload: {
          'players': [
            {
              'player_id': 'some-player-id',
              'player_session': 'some-session-id',
              'player_displayname': 'some-displayname',
              'player_icon': '😀',
            }
          ]
        }),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having((s) => s.players, 'player list', isNotEmpty),
      ],
    );

    blocTest(
      'session state update: no payload',
      build: () => SessionBloc(),
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onSessionStateUpdate, payload: null),
      ),
      errors: () => [contains('null payload')],
    );

    blocTest(
      'session state update: payload',
      build: () => SessionBloc(),
      act: (b) => b.add(
        SocketSessionEvent(
          socket: socket,
          event: onSessionStateUpdate,
          payload: {
            'session_id': 'some-id',
            'session_code': 'ABCDEF',
            'session_start': DateTime.now().toIso8601String(),
            'session_state': 'waiting',
            'session_word': null,
            'session_max_players': 5,
            'session_round_count': 5,
            'session_turn_duration': 60,
            'session_owner': 'some-owner-id',
            'end': null,
          },
        ),
      ),
      expect: () => [
        const TypeMatcher<SessionState>()
            .having((state) => state.info.id, 'has id', 'some-id')
            .having((s) => s.info.owner, 'owner id', 'some-owner-id'),
      ],
    );

    blocTest(
      'next turn: no payload',
      build: () => SessionBloc(),
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onSessionNextTurn, payload: null),
      ),
      errors: () => [contains('null payload')],
    );

    blocTest(
      'next turn: payload (my turn)',
      build: () => SessionBloc(),
      seed: () => SessionState(
        self: const Player(
          playerId: 'some-id',
        ),
      ),
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onSessionNextTurn, payload: {
          'turn_id': 'some-id',
          'turn_session': 'some-id',
          'turn_player': 'some-id',
          'turn_overall': 0,
          'turn_skipped': null,
          'turn_ended': null,
        }),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having((s) => s.effect, 'my turn', isA<MyTurnEffect>()),
      ],
    );

    blocTest(
      'next turn: payload (not my turn)',
      build: () => SessionBloc(),
      seed: () => SessionState(
        self: const Player(
          playerId: 'some-id',
        ),
      ),
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onSessionNextTurn, payload: {
          'turn_id': 'some-id',
          'turn_session': 'some-id',
          'turn_player': 'some-other-id',
          'turn_overall': 0,
          'turn_skipped': null,
          'turn_ended': null,
        }),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having((s) => s.effect, 'not my turn', isA<NotMyTurnEffect>()),
      ],
    );

    blocTest(
      'on finish',
      build: () => SessionBloc(),
      act: (b) => b.add(
        SocketSessionEvent(socket: socket, event: onSessionFinished),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having((state) => state.effect, 'end session', isA<EndSessionEffect>()),
      ],
    );

    blocTest(
      'on drawables: no payload',
      build: () => SessionBloc(),
      act: (b) => b.add(SocketSessionEvent(socket: socket, event: onSessionDrawables, payload: null)),
      errors: () => [contains('null payload')],
    );

    blocTest(
      'on drawables: payload',
      build: () => SessionBloc(),
      act: (b) => b.add(
        SocketSessionEvent(
          socket: socket,
          event: onSessionDrawables,
          payload: {
            'id': '-',
            'color': '#3e3e3e',
            'strokeWidth': 1.5,
            'path': '[10, 5];[1.23, 5]',
          },
        ),
      ),
      expect: () => [
        const TypeMatcher<SessionState>().having((s) => s.effect, 'drawable update', isA<UpdateDrawableEffect>()),
      ],
    );
  });

  group('DrawableSessionEvent', () {
    blocTest(
      'create',
      build: () => SessionBloc(),
      setUp: () {
        when(() => socket.emit(emitSessionDrawing, any())).thenReturn(null);
      },
      act: (b) => b.add(
          DrawableSessionEvent(socket: socket, drawable: const PaintDrawable(), eventType: DrawableEventType.create)),
      verify: (b) {
        verify(() => socket.emit(emitSessionDrawing, any()));
      },
    );
    blocTest(
      'update',
      build: () => SessionBloc(),
      setUp: () {
        when(() => socket.emit(emitSessionDrawing, any())).thenReturn(null);
      },
      act: (b) => b.add(
          DrawableSessionEvent(socket: socket, drawable: const PaintDrawable(), eventType: DrawableEventType.update)),
      verify: (b) {
        verify(() => socket.emit(emitSessionDrawing, any()));
      },
    );

    blocTest(
      'commit',
      build: () => SessionBloc(),
      setUp: () {
        when(() => socket.emit(emitSessionCommitDrawing, any())).thenReturn(null);
      },
      act: (b) => b.add(
          DrawableSessionEvent(socket: socket, drawable: const PaintDrawable(), eventType: DrawableEventType.commit)),
      verify: (b) {
        verify(() => socket.emit(emitSessionCommitDrawing, any()));
      },
    );
  });
}
