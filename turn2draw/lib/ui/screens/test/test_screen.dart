import 'package:flutter/material.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';
import 'package:turn2draw/ui/common/canvas/drawable_canvas.dart';

class TestDrawingScreen extends StatefulWidget {
  const TestDrawingScreen({super.key});

  @override
  State<TestDrawingScreen> createState() => _TestDrawingScreenState();
}

class _TestDrawingScreenState extends State<TestDrawingScreen> {
  List<PaintDrawable> drawables = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (drawables.isEmpty) return;
                drawables.removeLast();
              });
            },
            icon: const Icon(Icons.clear_all_rounded),
          ),
        ],
      ),
      body: DrawableCanvas(
        drawables: drawables,
        drawableCreated: (drawable) {
          setState(() => drawables.add(drawable));
        },
        drawableChanged: (drawable) {
          setState(() {
            final index = drawables.indexWhere((element) => element.id == drawable.id);
            if (index <= -1) return;
            drawables[index] = drawable;
          });
        },
        drawableCompleted: (drawable) {},
      ),
    );
  }
}
