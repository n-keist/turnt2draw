import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:turn2draw/locator.dart';
import 'package:turn2draw/ui/_state/home/home_event.dart';
import 'package:turn2draw/ui/_state/session/events/init_event.dart';
import 'package:turn2draw/ui/screens/home/home.dart';
import 'package:turn2draw/ui/screens/session/session.dart';

final router = GoRouter(
  debugLogDiagnostics: kDebugMode,
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => BlocProvider(
        lazy: false,
        create: (context) => HomeBloc(
          wordRepository: context.read<WordRepository>(),
          playerService: locator<PlayerService>(),
          //sessionService: locator<SessionService>(),
        )..add(HomeInitEvent()),
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/session/:id',
      builder: (context, state) {
        final sessionId = state.pathParameters['id'];
        if (sessionId == null || sessionId.isEmpty) context.go('/');
        return BlocProvider(
          lazy: false,
          create: (context) => SessionBloc(
            sessionService: locator<SessionService>(),
            playerService: locator<PlayerService>(),
          )..add(InitSessionEvent()),
          child: const SessionScreen(),
        );
      },
    ),
  ],
);
