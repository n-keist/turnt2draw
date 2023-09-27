import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:turn2draw/config/dev.dart';
import 'package:turn2draw/ui/_state/home/effects/session_effect.dart';
import 'package:turn2draw/ui/_state/home/home_event.dart';
import 'package:turn2draw/ui/common/input/pm_button_bar.dart';
import 'package:turn2draw/ui/screens/home/home.dart';
import 'package:turn2draw/ui/screens/home/modal/scan_session_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/svg_icons/pencil.svg'),
            const SizedBox(width: 16.0),
            const Text('turnt2draw'),
            const SizedBox(width: 16.0),
            Transform.flip(
              flipX: true,
              child: SvgPicture.asset('assets/svg_icons/pencil.svg'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (kDebugMode) {
            return context
                .read<HomeBloc>()
                .add(JoinSessionEvent(sessionId: devSessionId));
          }
          final result = await showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            builder: (modalContext) => const ScanSessionModal(),
          );
          if (result == null) return;
          if (result is StateError) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            return;
          }
          if (result is String) {
            if (!context.mounted) return;
            context.read<HomeBloc>().add(JoinSessionEvent(sessionId: result));
          }
        },
        child: const Icon(Icons.search_off_rounded),
      ),
      body: BlocListener<HomeBloc, HomeState>(
        listenWhen: (prev, curr) => curr.effect != prev.effect,
        listener: (context, state) async {
          if (state.effect != null && state.effect is SessionEffect) {
            final effect = state.effect as SessionEffect;
            await Future.delayed(const Duration(milliseconds: 25));
            if (context.mounted) context.push('/session/${effect.sessionId}');
          }
        },
        child: Scrollbar(
          controller: PrimaryScrollController.of(context),
          child: SingleChildScrollView(
            controller: PrimaryScrollController.of(context),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text('Player Count'),
                    ),
                    Expanded(
                      flex: 3,
                      child: BlocSelector<HomeBloc, HomeState, int>(
                        selector: (state) => state.maxPlayers,
                        builder: (context, maxPlayers) {
                          return PlusMinusButtonBar(
                            removeCallback: () => context.read<HomeBloc>().add(
                                  ChangeCountOnSubjectEvent(
                                    type: CountEventType.remove,
                                    subject: CountSubject.playerCount,
                                  ),
                                ),
                            addCallback: () => context.read<HomeBloc>().add(
                                  ChangeCountOnSubjectEvent(
                                    type: CountEventType.add,
                                    subject: CountSubject.playerCount,
                                  ),
                                ),
                            value: maxPlayers,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text('Rounds'),
                    ),
                    Expanded(
                      flex: 3,
                      child: BlocSelector<HomeBloc, HomeState, int>(
                        selector: (state) => state.roundCount,
                        builder: (context, roundCount) {
                          return PlusMinusButtonBar(
                            removeCallback: () => context.read<HomeBloc>().add(
                                  ChangeCountOnSubjectEvent(
                                    type: CountEventType.remove,
                                    subject: CountSubject.roundCount,
                                  ),
                                ),
                            addCallback: () => context.read<HomeBloc>().add(
                                  ChangeCountOnSubjectEvent(
                                    type: CountEventType.add,
                                    subject: CountSubject.roundCount,
                                  ),
                                ),
                            value: roundCount,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text('Turn Duration'),
                    ),
                    Expanded(
                      flex: 3,
                      child: BlocSelector<HomeBloc, HomeState, int>(
                        selector: (state) => state.turnDuration,
                        builder: (context, turnDuration) {
                          return PlusMinusButtonBar(
                            removeCallback: () => context.read<HomeBloc>().add(
                                  ChangeCountOnSubjectEvent(
                                    type: CountEventType.remove,
                                    subject: CountSubject.turnDuration,
                                  ),
                                ),
                            addCallback: () => context.read<HomeBloc>().add(
                                  ChangeCountOnSubjectEvent(
                                    type: CountEventType.add,
                                    subject: CountSubject.turnDuration,
                                  ),
                                ),
                            value: turnDuration,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                BlocSelector<HomeBloc, HomeState, String?>(
                  selector: (state) => state.word,
                  builder: (context, word) {
                    if (word == null) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'freestyle drawing',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context
                                .read<HomeBloc>()
                                .add(PickNewWordEvent()),
                            child: const Text('pick random topic'),
                          ),
                        ],
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          word,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context
                                    .read<HomeBloc>()
                                    .add(ClearWordEvent()),
                                child: const Text('freestyle drawing'),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context
                                    .read<HomeBloc>()
                                    .add(PickNewWordEvent()),
                                child: const Text('pick new topic'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                TextButton(
                  onPressed: () =>
                      context.read<HomeBloc>().add(CreateSessionEvent()),
                  child: const Text('start'),
                ),
                TextButton(
                  onPressed: () => context.go('/test'),
                  child: const Text('test'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
