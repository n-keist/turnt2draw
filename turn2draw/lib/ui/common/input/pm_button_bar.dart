import 'package:flutter/material.dart';

class PlusMinusButtonBar extends StatelessWidget {
  const PlusMinusButtonBar({super.key, this.value = 0, this.removeCallback, this.addCallback});

  final VoidCallback? removeCallback;
  final VoidCallback? addCallback;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        FloatingActionButton.small(
          heroTag: UniqueKey(),
          onPressed: removeCallback,
          child: const Icon(Icons.remove_rounded),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        FloatingActionButton.small(
          heroTag: UniqueKey(),
          onPressed: addCallback,
          child: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
