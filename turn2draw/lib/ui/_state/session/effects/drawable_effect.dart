import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:turn2draw/ui/_state/effect.dart';

class UpdateDrawableEffect extends Effect {
  UpdateDrawableEffect({required this.drawable});
  final PaintDrawable drawable;
}
