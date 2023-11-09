import 'dart:io';
import 'dart:math' show pi;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turn2draw/config/http.dart';
import 'package:turn2draw/config/logger.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'package:turn2draw/ui/_state/common_effects/dialog_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/kicked_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/session_effect.dart';
import 'package:turn2draw/ui/common/dialog/message_dialog.dart';
import 'package:turn2draw/ui/screens/session/modal/confirm_exit.dart';
import 'package:turn2draw/ui/screens/session/session.dart';
import 'package:turn2draw/ui/screens/session/view_state/drawing.dart';
import 'package:turn2draw/ui/screens/session/view_state/waiting.dart';

import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late socket_io.Socket socket;

  late ConfettiController confettiController;

  @override
  void initState() {
    confettiController = ConfettiController(duration: const Duration(seconds: 6));

    socket = socket_io.io(
      httpBaseUrl,
      socket_io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().setAuth({'token': httpToken}).build(),
    )..connect();

    socket.onAny((event, data) {
      if (!context.mounted) return;
      logger.d([event, data]);
      context.read<SessionBloc>().add(
            SocketSessionEvent(
              socket: socket,
              event: event,
              payload: (data != null ? Map<String, dynamic>.from(data) : null),
            ),
          );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = GoRouterState.of(context).pathParameters['id'];
      if (id != null && id.isNotEmpty) {
        context.read<SessionBloc>().add(LocalSessionEvent(type: LocalSessionEventType.find, sessionId: id));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        final result = await showModalBottomSheet<bool?>(context: context, builder: (_) => const ConfirmExitModal());
        if ((result ?? false) && context.mounted) Navigator.of(context).pop();
      },
      child: BlocListener<SessionBloc, SessionState>(
        listenWhen: (_, __) => true,
        listener: _sessionListener,
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: BlocSelector<SessionBloc, SessionState, SessionInfo>(
                selector: (state) => state.info,
                builder: (context, sessionInfo) {
                  return switch (sessionInfo.state) {
                    GameState.waiting => SessionWaitingView(socket: socket),
                    GameState.playing => SessionDrawingView(socket: socket),
                    _ => throw 'you should not be here!',
                  };
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                colors: const [Colors.orangeAccent, Colors.purple, Colors.blueAccent],
                blastDirection: pi / 2,
                maxBlastForce: 6.5, // set a lower max blast force
                minBlastForce: 2.5, // set a lower min blast force
                emissionFrequency: 0.08,
                numberOfParticles: 12, // a lot of particles at once
                gravity: .125,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sessionListener(BuildContext context, SessionState state) async {
    if (state.effect != null && state.effect is EndSessionEffect) {
      setState(() => confettiController.play());
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
            content: Text(
              'Save Result to ${Platform.isIOS ? 'Camera Roll' : 'Gallery'}?',
            ),
            action: SnackBarAction(
              label: 'Save',
              onPressed: () => context.read<SessionBloc>().add(SessionSaveResultEvent()),
            ),
          ),
        );
      return;
    }
    if (state.effect != null && state.effect is PlayerKickedEffect) {
      return context.go('/?why=KICKED');
    }
    if (state.effect != null && state.effect is DialogEffect) {
      final effect = state.effect as DialogEffect;
      showModalBottomSheet(
        context: context,
        builder: (_) => MessageDialog(title: effect.title, body: effect.body),
      );
    }
  }
}
