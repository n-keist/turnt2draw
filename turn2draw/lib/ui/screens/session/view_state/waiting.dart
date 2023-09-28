import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:turn2draw/data/model/player.dart';
import 'package:turn2draw/data/model/session_info.dart';
import 'package:turn2draw/ui/screens/session/modal/share_modal.dart';
import 'package:turn2draw/ui/screens/session/session.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SessionWaitingView extends StatelessWidget {
  const SessionWaitingView({required this.socket, super.key});

  final socket_io.Socket socket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('lobby'),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              useSafeArea: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              builder: (modalContext) => SessionShareModal(
                sessionId: context.read<SessionBloc>().state.info.id,
              ),
            ),
            icon: Icon(Icons.adaptive.share_rounded),
          ),
        ],
      ),
      body: Scrollbar(
        controller: PrimaryScrollController.of(context),
        child: SingleChildScrollView(
          controller: PrimaryScrollController.of(context),
          padding: const EdgeInsets.all(24.0),
          child: Column(
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
                  final players = List<Player>.from(state.players)..sort;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      final player = players.elementAt(index);
                      return _buildPlayerRow(
                        player,
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
              const SizedBox(height: 24.0),
              BlocSelector<SessionBloc, SessionState, bool>(
                selector: (state) => state.self.playerId == state.info.owner,
                builder: (context, isOwner) {
                  if (!isOwner) return const SizedBox.shrink();
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.read<SessionBloc>().add(
                                LocalSessionEvent(
                                  type: LocalSessionEventType.begin,
                                ),
                              ),
                          child: const Text('begin'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow(Player player, {bool isOwner = false, bool isSelf = false, bool showKickPlayer = false}) {
    return ListTile(
      leading: CircleAvatar(
        child: isOwner
            ? SvgPicture.asset(
                'assets/svg_icons/crown.svg',
                colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
              )
            : null,
      ),
      title: Text(player.playerDisplayname),
      subtitle: isSelf ? const Text('(you)') : null,
      trailing: (showKickPlayer && !isSelf)
          ? IconButton(
              onPressed: () => false,
              icon: const Icon(Icons.handyman_rounded),
            )
          : null,
    );
  }
}
