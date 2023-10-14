import 'package:flutter_test/flutter_test.dart';
import 'package:turn2draw/ui/_state/effect.dart';

class TestEffect extends Effect {}

void main() {
  test('effect has id', () {
    final effect = TestEffect();
    expect(effect.effectId, isA<String>());
    expect(effect.effectId, isNotEmpty);
  });
}
