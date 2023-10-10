import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/ui/_state/common_effects/dialog_effect.dart';
import 'package:turn2draw/ui/_state/home/effects/session_effect.dart';
import 'package:turn2draw/ui/_state/home/home_event.dart';
import 'package:turn2draw/ui/common/brand.dart';
import 'package:turn2draw/ui/common/canvas/drawable_canvas.dart';
import 'package:turn2draw/ui/common/dialog/message_dialog.dart';
import 'package:turn2draw/ui/common/input/wide_button.dart';
import 'package:turn2draw/ui/screens/home/home.dart';
import 'package:turn2draw/ui/screens/home/modal/create_game_modal.dart';
import 'package:turn2draw/ui/screens/home/modal/settings_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final drawables = <PaintDrawable>[];

  final colors = <Color>[
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.green,
  ];

  late Color currentColor;

  @override
  void initState() {
    currentColor = colors[0];
    context.read<HomeBloc>().add(HomeInitEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: BlocSelector<HomeBloc, HomeState, Player>(
          selector: (state) => state.self,
          builder: (context, player) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(
                    player.playerIcon,
                    style: const TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(player.playerDisplayname),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SettingsModal(
                  usernameCallback: () {
                    context.read<HomeBloc>().add(PlayerEvent());
                    HapticFeedback.lightImpact();
                  },
                  iconCallback: () {
                    context.read<HomeBloc>().add(PlayerEvent(type: PlayerEventType.regenerateIcon));
                    HapticFeedback.lightImpact();
                  },
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: BlocListener<HomeBloc, HomeState>(
        listenWhen: (prev, curr) => curr.effect != prev.effect,
        listener: (context, state) async {
          if (state.effect != null && state.effect is SessionEffect) {
            final effect = state.effect as SessionEffect;
            await Future.delayed(const Duration(milliseconds: 25));
            if (context.mounted) context.push('/session/${effect.sessionId}');
            return;
          }
          if (state.effect != null && state.effect is DialogEffect) {
            final effect = state.effect as DialogEffect;
            showModalBottomSheet(
              context: context,
              isDismissible: effect.dismissable,
              builder: (_) => MessageDialog(
                title: effect.title,
                body: effect.body,
                callbackText: effect.callbackText,
                callback: effect.dismissable ? () => context.read<HomeBloc>().add(HomeInitEvent()) : null,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  DrawableCanvas(
                    drawables: drawables,
                    enabled: true,
                    color: currentColor,
                    strokeWidth: 6.125,
                    drawableCreated: (drawable) {
                      setState(() => drawables.add(drawable));
                    },
                    drawableChanged: (drawable) {
                      final drawableIndex = drawables.indexWhere((d) => d.id == drawable.id);
                      if (drawableIndex <= -1) return;
                      setState(() => drawables[drawableIndex] = drawable);
                    },
                    drawableCompleted: (_) {
                      setState(() => currentColor = colors[Random().nextInt(colors.length - 1)]);
                    },
                  ),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Brand(),
                    ),
                  ),
                ],
              ),
            ),
            const WideButton(
              color: Colors.deepPurple,
              label: 'FIND GAME',
              icon: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            WideButton(
              color: Colors.purple,
              label: 'CREATE GAME',
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 40,
              ),
              callback: _handleCreateGame,
            ),
            WideButton(
              color: Colors.orangeAccent,
              label: 'JOIN RANDOM GAME',
              icon: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 40,
              ),
              callback: () => context.read<HomeBloc>().add(JoinSessionEvent()),
            )
          ],
        ),
      ),
    );
  }

  void _handleCreateGame() async {
    final result = await showModalBottomSheet<CreateSessionConfig?>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CreateGameModal(),
    );
    if (result != null && context.mounted) {
      context.read<HomeBloc>().add(CreateSessionEvent(config: result));
    }
  }
}
