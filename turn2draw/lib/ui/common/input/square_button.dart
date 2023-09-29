import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({super.key, required this.icon, this.callback, this.color = Colors.purple, this.size = 60});

  final Widget icon;
  final VoidCallback? callback;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: SizedBox.fromSize(
        size: Size.square(size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
