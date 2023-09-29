import 'package:flutter/material.dart';

class WideButton extends StatelessWidget {
  const WideButton(
      {super.key, this.icon, required this.label, this.callback, this.color = Colors.purple, this.height = 80});

  final Widget? icon;
  final String label;
  final VoidCallback? callback;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: SizedBox.fromSize(
        size: Size.fromHeight(height),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                if (icon != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: icon,
                  ),
                Align(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
