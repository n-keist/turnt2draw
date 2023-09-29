import 'dart:math';

import 'package:flutter/material.dart';
import 'package:turn2draw/data/model/create_session_config.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/locator.dart';
import 'package:turn2draw/ui/common/input/pm_button_bar.dart';
import 'package:turn2draw/ui/common/input/square_button.dart';
import 'package:turn2draw/ui/common/input/wide_button.dart';

class CreateGameModal extends StatefulWidget {
  const CreateGameModal({super.key});

  @override
  State<CreateGameModal> createState() => _CreateGameModalState();
}

class _CreateGameModalState extends State<CreateGameModal> {
  CreateSessionConfig config = CreateSessionConfig.empty();

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Text(
              'PLAYERS',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: PlusMinusButtonBar(
              value: config.maxPlayers,
              removeCallback: () {
                if (config.maxPlayers <= 2) return;
                setState(
                  () => config = config.copyWith(maxPlayers: () => config.maxPlayers - 1),
                );
              },
              addCallback: () {
                if (config.maxPlayers >= 99) return;
                setState(
                  () => config = config.copyWith(
                    maxPlayers: () => config.maxPlayers + 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Text(
              'TURNS',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: PlusMinusButtonBar(
              value: config.roundCount,
              color: Colors.purple,
              removeCallback: () {
                if (config.roundCount <= 2) return;
                setState(
                  () => config = config.copyWith(roundCount: () => config.roundCount - 1),
                );
              },
              addCallback: () {
                if (config.roundCount >= 99) return;
                setState(
                  () => config = config.copyWith(roundCount: () => config.roundCount + 1),
                );
              },
            ),
          ),
        ],
      ),
      Row(
        children: [
          const Expanded(
            flex: 1,
            child: Text(
              'TIME',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: PlusMinusButtonBar(
              value: config.turnDuration,
              color: Colors.purple,
              addCallback: () {
                if (config.turnDuration >= 120) return;
                setState(
                  () => config = config.copyWith(turnDuration: () => config.turnDuration + 5),
                );
              },
              removeCallback: () {
                if (config.turnDuration <= 5) return;
                setState(
                  () => config = config.copyWith(turnDuration: () => config.turnDuration - 5),
                );
              },
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: WideButton(
              color: Colors.pink,
              height: 60,
              label: config.word?.toUpperCase() ?? 'FREESTYLE',
              icon: config.word != null ? const Icon(Icons.refresh_rounded, color: Colors.white) : null,
              callback: () async {
                final words = await locator<WordRepository>().getWords();
                final topic = words.elementAt(Random().nextInt(words.length - 1));
                setState(() => config = config.copyWith(word: () => topic));
              },
            ),
          ),
          const SizedBox(width: 6.0),
          SquareButton(
            icon: const Icon(Icons.clear_rounded, color: Colors.white),
            color: Colors.pink,
            size: 60,
            callback: () {
              setState(() => config = config.copyWith(word: () => null));
            },
          ),
        ],
      ),
      WideButton(
        label: 'START GAME',
        color: Colors.orange,
        icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
        callback: () => Navigator.of(context).pop(config),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
      shrinkWrap: true,
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
      separatorBuilder: (_, __) => const SizedBox(height: 6.0),
    );
  }
}
