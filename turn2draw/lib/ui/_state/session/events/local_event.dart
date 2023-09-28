part of '../session_event.dart';

enum LocalSessionEventType { create, find, begin }

@immutable
class LocalSessionEvent extends SessionEvent {
  LocalSessionEvent({required this.type, this.sessionId = ''});

  final LocalSessionEventType type;
  final String sessionId;
}
