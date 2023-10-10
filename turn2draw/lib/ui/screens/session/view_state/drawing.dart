import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
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
  double indicatorValue = 0.0;

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
      appBar: AppBar(
        centerTitle: false,
        title: Text(context.read<SessionBloc>().state.info.word ?? 'freestyle'),
        actions: [
          IconButton(
            onPressed: () => false,
            icon: const Icon(Icons.logout_rounded),
          ),
          IconButton(
            onPressed: () => false,
            icon: const Icon(Icons.skip_next_rounded),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: indicatorValue,
            borderRadius: BorderRadius.circular(4.0),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: BlocListener<SessionBloc, SessionState>(
        listener: _sessionListener,
        child: AspectRatio(
          aspectRatio: 9 / 12,
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
      indicatorValue = 1.0;
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (turnDuration == 0) timer.cancel();
        turnDuration -= 1;
        setState(() => indicatorValue = turnDuration / state.info.turnDuration);
      });
    }
    if (state.effect != null && state.effect is MyTurnEffect) {
      setState(() => myTurn = true);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            showCloseIcon: true,
            closeIconColor: Colors.white,
            content: Row(
              children: [
                const Icon(Icons.brush_rounded, color: Colors.white),
                const SizedBox(width: 6.0),
                Text('${state.info.turnDuration} seconds, draw!')
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
