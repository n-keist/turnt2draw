import 'package:nanoid2/nanoid2.dart';

abstract class Effect {
  Effect() : _effectId = nanoid();

  final String _effectId;

  String get effectId => _effectId;
}
