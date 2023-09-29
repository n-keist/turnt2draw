import 'package:flutter/material.dart';
import 'package:turn2draw/ui/common/input/square_button.dart';

class PlusMinusButtonBar extends StatelessWidget {
  const PlusMinusButtonBar(
      {super.key, this.value = 0, this.removeCallback, this.addCallback, this.color = Colors.deepPurple});

  final VoidCallback? removeCallback;
  final VoidCallback? addCallback;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SquareButton(
          icon: const Icon(Icons.remove_rounded, color: Colors.white),
          callback: removeCallback,
          color: color,
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SquareButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          callback: addCallback,
          color: color,
        ),
      ],
    );
  }
}
