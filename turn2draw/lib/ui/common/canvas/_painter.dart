part of 'drawable_canvas.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter({this.drawables = const []});

  final List<PaintDrawable> drawables;

  @override
  void paint(Canvas canvas, Size size) {
    for (final drawable in drawables) {
      final paint = Paint()
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.butt
        ..color = drawable.color
        ..strokeWidth = drawable.strokeWidth;

      for (int i = 0; i < drawable.offsets.length; i++) {
        final point = drawable.offsets.elementAtOrNull(i);
        final nextPoint = drawable.offsets.elementAtOrNull(i + 1);
        if (point == null || nextPoint == null) continue;
        canvas.drawLine(point, nextPoint, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => oldDelegate.drawables != drawables;
}
