import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'package:turn2draw/ui/common/input/wide_button.dart';
import 'package:turn2draw/ui/screens/session/components/player_row.dart';
import 'package:turn2draw/ui/screens/session/session.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SessionWaitingView extends StatelessWidget {
  const SessionWaitingView({required this.socket, super.key});

  final socket_io.Socket socket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting...'),
      ),
      bottomNavigationBar: BlocSelector<SessionBloc, SessionState, bool>(
        selector: (state) => state.self.playerId == state.info.owner,
        builder: (context, isOwner) {
          if (!isOwner) return const SizedBox.shrink();
          return WideButton(
            label: 'START GAME',
            foregroundColor: Colors.white,
            icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
            callback: () => context.read<SessionBloc>().add(LocalSessionEvent(type: LocalSessionEventType.begin)),
          );
        },
      ),
      body: Scrollbar(
        controller: PrimaryScrollController.of(context),
        child: SingleChildScrollView(
          controller: PrimaryScrollController.of(context),
          padding: const EdgeInsets.all(24.0),
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                'Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '(let others participate by sharing the code below)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                ),
                child: BlocSelector<SessionBloc, SessionState, SessionInfo>(
                  selector: (state) => state.info,
                  builder: (context, info) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: info.code
                          .split('')
                          .map<Widget>(
                            (char) => Text(
                              char,
                              style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              const Text(
                'Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              BlocSelector<SessionBloc, SessionState, SessionInfo>(
                selector: (state) => state.info,
                builder: (context, info) {
                  return ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    prototypeItem: const ListTile(dense: true),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                    ),
                    children: [
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.question_mark_rounded),
                        title: const Text('Topic'),
                        subtitle: Text(info.word ?? '-'),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.brush_rounded),
                        title: const Text('Rounds'),
                        subtitle: Text(info.roundCount.toString()),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.watch_later_rounded),
                        title: const Text('Turn Duration'),
                        subtitle: Text('${info.turnDuration} seconds'),
                      ),
                    ],
                  );
                },
              ),
              const Text(
                'Players',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              BlocBuilder<SessionBloc, SessionState>(
                builder: (context, state) {
                  final self = state.self;
                  final players = state.players;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      final player = players.elementAt(index);
                      return SessionPlayerRow(
                        player: player,
                        isOwner: player.playerId == state.info.owner,
                        isSelf: self.playerId == player.playerId,
                        showKickPlayer: self.playerId == state.info.owner,
                        kickCallback: () => context
                            .read<SessionBloc>()
                            .add(PlayerSocketEvent(socket: socket, player: player, type: PlayerSocketEventType.kick)),
                      );
                    },
                    itemCount: players.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
