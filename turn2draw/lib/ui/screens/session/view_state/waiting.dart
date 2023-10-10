import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
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
                    children: [
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.edit_rounded),
                        title: const Text('Topic'),
                        subtitle: Text(info.word ?? '-'),
                      ),
                      ListTile(
                        dense: true,
                        leading: SvgPicture.asset(
                          'assets/svg_icons/brush.svg',
                          width: 20,
                        ),
                        title: const Text('Rounds'),
                        subtitle: Text(info.roundCount.toString()),
                      ),
                      ListTile(
                        dense: true,
                        leading: SvgPicture.asset('assets/svg_icons/stopwatch.svg', width: 20),
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
                      );
                    },
                    itemCount: players.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
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
