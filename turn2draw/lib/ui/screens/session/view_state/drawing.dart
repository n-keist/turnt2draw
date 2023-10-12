import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/ui/_state/session/effects/turn_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/drawable_effect.dart';
import 'package:turn2draw/ui/_state/session/session_bloc.dart';
import 'package:turn2draw/ui/_state/session/session_event.dart';
import 'package:turn2draw/ui/_state/session/session_state.dart';
import 'package:turn2draw/ui/common/canvas/drawable_canvas.dart';
import 'package:turn2draw/ui/common/input/square_button.dart';
import 'package:turn2draw/ui/common/input/wide_button.dart';
import 'package:turn2draw/ui/screens/session/modal/color_picker_modal.dart';
import 'package:turn2draw/ui/screens/session/modal/stroke_width_modal.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SessionDrawingView extends StatefulWidget {
  const SessionDrawingView({required this.socket, super.key});

  final socket_io.Socket socket;

  @override
  State<SessionDrawingView> createState() => _SessionDrawingViewState();
}

class _SessionDrawingViewState extends State<SessionDrawingView> {
  final strokeWidthNotifier = ValueNotifier<double>(2.25);
  final colorNotifier = ValueNotifier<Color>(Colors.blue);

  bool myTurn = false;
  List<PaintDrawable> localDrawables = <PaintDrawable>[];

  int turnDuration = 0;

  String turnTime = '00:00';

  Timer? timer;

  @override
  void initState() {
    super.initState();
    // fires listener for initial state (first person to draw)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionListener(context, context.read<SessionBloc>().state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocSelector<SessionBloc, SessionState, Player?>(
                    selector: (state) => state.players.firstWhereOrNull((p) => p.playerId == state.turnInfo.turnPlayer),
                    builder: (context, state) {
                      if (state == null) return const SizedBox.shrink();
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            child: Text(
                              state.playerIcon,
                              style: const TextStyle(
                                fontSize: 22.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            state.playerDisplayname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded),
                      const SizedBox(width: 6.0),
                      Flexible(
                        child: Text(
                          turnTime,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocListener<SessionBloc, SessionState>(
        listener: _sessionListener,
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          child: DrawableCanvas(
            drawables: localDrawables,
            color: colorNotifier.value,
            enabled: myTurn,
            strokeWidth: strokeWidthNotifier.value,
            drawableCreated: (drawable) {
              setState(() => localDrawables.add(drawable));
              context.read<SessionBloc>().add(
                  DrawableSessionEvent(socket: widget.socket, drawable: drawable, eventType: DrawableEventType.create));
            },
            drawableChanged: (drawable) {
              setState(() {
                final index = localDrawables.indexWhere((element) => element.id == drawable.id);
                if (index <= -1) return;
                localDrawables[index] = drawable;
                context.read<SessionBloc>().add(DrawableSessionEvent(
                    socket: widget.socket, drawable: drawable, eventType: DrawableEventType.create));
              });
            },
            drawableCompleted: (drawable) => context.read<SessionBloc>().add(
                DrawableSessionEvent(socket: widget.socket, drawable: drawable, eventType: DrawableEventType.commit)),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: myTurn ? 1.0 : 0.125,
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: colorNotifier,
                builder: (context, value, _) {
                  final foregroundColor = value.computeLuminance() > 0.179 ? Colors.black : Colors.white;
                  return WideButton(
                    color: value,
                    icon: Icon(Icons.brush_rounded, color: foregroundColor),
                    foregroundColor: foregroundColor,
                    label: 'COLOR',
                    callback: myTurn ? _colorPickerCallback : null,
                  );
                },
              ),
            ),
            SquareButton(
              callback: myTurn ? _strokeWidthCallback : null,
              icon: const Icon(Icons.strikethrough_s_rounded),
              size: 80,
            ),
          ],
        ),
      ),
    );
  }

  void _sessionListener(BuildContext context, SessionState state) {
    if (state.effect != null && (state.effect is MyTurnEffect || state.effect is NotMyTurnEffect)) {
      turnDuration = state.info.turnDuration;
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (turnDuration == 0) timer.cancel();
        final duration = Duration(seconds: turnDuration);
        setState(() {
          turnDuration -= 1;
          if (duration.inMinutes == 0) {
            turnTime = duration.inSeconds.toString().padLeft(2, '0');
            return;
          }
          turnTime =
              '${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.toString().padLeft(2, '0')}';
        });
      });
    }
    if (state.effect != null && state.effect is MyTurnEffect) {
      setState(() => myTurn = true);
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            closeIconColor: Colors.white,
            content: Row(
              children: [
                Icon(Icons.brush_rounded, color: Colors.white),
                SizedBox(width: 6.0),
                Text('It\'s your turn!')
              ],
            ),
          ),
        );
    }
    if (state.effect != null && state.effect is NotMyTurnEffect) {
      setState(() => myTurn = false);
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    if (state.effect != null && state.effect is UpdateDrawableEffect) {
      final effect = state.effect as UpdateDrawableEffect;
      final currentDrawableIndex = localDrawables.indexWhere((element) => element.id == effect.drawable.id);
      if (currentDrawableIndex <= -1) {
        setState(() => localDrawables.add(effect.drawable));
        return;
      }
      setState(() => localDrawables[currentDrawableIndex] = effect.drawable);
      // TODO: merge new drawables into current drawables
    }
  }

  void _colorPickerCallback() async {
    showModalBottomSheet<Color?>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      isScrollControlled: true,
      builder: (context) => SessionColorPickerModal(colorNotifier: colorNotifier),
    );
  }

  void _strokeWidthCallback() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SessionStrokeWidthModal(strokeWidthNotifier: strokeWidthNotifier),
    );
  }
}
