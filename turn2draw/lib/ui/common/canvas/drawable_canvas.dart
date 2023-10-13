import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:turn2draw/data/service/settings_service.dart';
import 'package:turn2draw/locator.dart';

part '_painter.dart';

class DrawableCanvas extends StatefulWidget {
  const DrawableCanvas({
    super.key,
    this.color = Colors.blue,
    this.strokeWidth = 2.125,
    this.enabled = true,
    this.drawables = const [],
    this.drawableCreated,
    this.drawableChanged,
    this.drawableCompleted,
  });

  final Color color;
  final double strokeWidth;

  final bool enabled;

  final List<PaintDrawable> drawables;

  final Function(PaintDrawable)? drawableCreated;
  final Function(PaintDrawable)? drawableChanged;
  final Function(PaintDrawable)? drawableCompleted;

  @override
  State<DrawableCanvas> createState() => _DrawableCanvasState();
}

class _DrawableCanvasState extends State<DrawableCanvas> {
  PaintDrawable? _drawable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        if (!widget.enabled) return;
        setState(() {
          _drawable = PaintDrawable(
            id: nanoid(length: 24),
            offsets: [details.localPosition],
            strokeWidth: widget.strokeWidth,
            color: widget.color,
          );

          if (_drawable == null) return;
          widget.drawableCreated?.call(_drawable!);
        });
      },
      onPanUpdate: (details) {
        if (!widget.enabled) return;
        if (_drawable == null) return;

        if (locator<SettingsService>().settings.hapticFeedback) HapticFeedback.selectionClick();

        setState(() {
          _drawable = _drawable?.copyWith(
            offsets: () => List<Offset>.from(_drawable!.offsets)..add(details.localPosition),
          );
          widget.drawableChanged?.call(_drawable!);
        });
      },
      onPanEnd: (details) {
        if (!widget.enabled) return;
        if (_drawable == null) return;
        widget.drawableCompleted?.call(_drawable!);
        setState(() => _drawable = null);
      },
      child: CustomPaint(
        painter: CanvasPainter(
          drawables: widget.drawables + [if (_drawable != null) _drawable!],
        ),
        isComplex: true,
        willChange: true,
        child: const SizedBox.expand(),
      ),
    );
  }
}
