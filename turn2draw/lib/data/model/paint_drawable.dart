import 'package:flutter/material.dart';
import 'package:turn2draw/data/extension/fn_extension.dart';

class PaintDrawable {
  PaintDrawable({
    this.id = '',
    this.offsets = const [],
    this.color = Colors.blue,
    this.strokeWidth = 2.25,
  });

  PaintDrawable copyWith({
    List<Offset> Function()? offsets,
    Color Function()? color,
    double Function()? strokeWidth,
  }) {
    return PaintDrawable(
      id: id,
      offsets: offsets.callOrElse<List<Offset>>(orElse: this.offsets),
      color: color.callOrElse<Color>(orElse: this.color),
      strokeWidth: strokeWidth.callOrElse<double>(orElse: this.strokeWidth),
    );
  }

  final String id;
  final List<Offset> offsets;
  final Color color;
  final double strokeWidth;
}
