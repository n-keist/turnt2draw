import 'package:turn2draw/ui/_state/effect.dart';

enum SessionEffectType {
  created,
  joined;
}

class SessionEffect extends Effect {
  SessionEffect({required this.type, this.sessionId = ''});

  final SessionEffectType type;
  final String sessionId;
}
