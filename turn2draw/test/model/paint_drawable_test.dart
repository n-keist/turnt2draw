import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turn2draw/data/model/paint_drawable.dart';

void main() {
  test('copyWith works', () {
    const drawable = PaintDrawable();
    final copyDrawable = drawable.copyWith(
      color: () => Colors.grey,
    );

    expect(const PaintDrawable(color: Colors.grey), copyDrawable);
  });
}
