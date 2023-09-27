import 'dart:math';

abstract class Effect {
  Effect() : _effectId = Random().nextInt(25565);

  final int _effectId;

  int get effectId => _effectId;
}
