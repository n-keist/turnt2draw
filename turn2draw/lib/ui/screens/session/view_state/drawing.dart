import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/data/extension/double_extension.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:turn2draw/ui/_state/session/effects/turn_effect.dart';
import 'package:turn2draw/ui/_state/session/effects/drawable_effect.dart';
import 'package:turn2draw/ui/_state/session/session_bloc.dart';
import 'package:turn2draw/ui/_state/session/session_event.dart';
import 'package:turn2draw/ui/_state/session/session_state.dart';
import 'package:turn2draw/ui/common/canvas/drawable_canvas.dart';
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
  final turnNotifier = ValueNotifier<bool>(false);
  List<PaintDrawable> localDrawables = <PaintDrawable>[];
  Color color = Colors.blue;
  double strokeWidth = 2.125;
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
          child: ValueListenableBuilder<bool>(
            valueListenable: turnNotifier,
            builder: (context, value, _) {
              return DrawableCanvas(
                drawables: localDrawables,
                color: color,
                enabled: value,
                strokeWidth: strokeWidth,
                drawableCreated: (drawable) {
                  setState(() => localDrawables.add(drawable));
                  context.read<SessionBloc>().add(DrawableSessionEvent(
                      socket: widget.socket, drawable: drawable, eventType: DrawableEventType.create));
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
                drawableCompleted: (drawable) => context.read<SessionBloc>().add(DrawableSessionEvent(
                    socket: widget.socket, drawable: drawable, eventType: DrawableEventType.commit)),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: ValueListenableBuilder(
          valueListenable: turnNotifier,
          builder: (context, value, child) {
            if (!value) return const SizedBox.shrink();
            return child!;
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: 12.5,
              right: 12.5,
              bottom: MediaQuery.of(context).viewPadding.bottom.ifLessThanOrEqualTo(constraint: 6, orElse: 16),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.5),
                boxShadow: [
                  BoxShadow(spreadRadius: 5, blurRadius: 5, color: Colors.black.withOpacity(0.125)),
                ],
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: _colorPickerCallback,
                    icon: const Icon(Icons.brush_rounded),
                  ),
                  IconButton(
                    onPressed: _strokeWidthCallback,
                    icon: const Icon(Icons.linear_scale_rounded),
                  ),
                ],
              ),
            ),
          ),
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
      turnNotifier.value = true;
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
      turnNotifier.value = false;
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
    final color = await showModalBottomSheet<Color?>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
      isScrollControlled: true,
      builder: (context) => SessionColorPickerModal(lastColor: this.color),
    );
    if (color == null) return;
    setState(() => this.color = color);
  }

  void _strokeWidthCallback() async {
    final strokeWidth = await showModalBottomSheet(
      context: context,
      builder: (context) => SessionStrokeWidthModal(value: this.strokeWidth),
    );
    if (strokeWidth == null) return;
    setState(() => this.strokeWidth = strokeWidth);
  }
}
