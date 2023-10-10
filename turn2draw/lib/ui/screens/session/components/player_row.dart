import 'package:flutter/material.dart';
import 'package:turn2draw/data/extension/widget_extension.dart';
import 'package:turn2draw/data/model/player.dart';

class SessionPlayerRow extends StatelessWidget {
  const SessionPlayerRow(
      {super.key, required this.player, this.isOwner = false, this.isSelf = false, this.showKickPlayer = false});

  final bool isOwner, isSelf, showKickPlayer;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          player.playerIcon,
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
      title: Text(player.playerDisplayname),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (isOwner) const Text('(owner)'),
          if (isSelf) const Text('(you)'),
        ],
      ),
      trailing: IconButton(
        onPressed: () => false,
        icon: const Icon(Icons.handyman_rounded),
      ).showWhen(() => showKickPlayer && !isSelf),
    );
  }
}
