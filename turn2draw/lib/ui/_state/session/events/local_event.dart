part of '../session_event.dart';

enum LocalSessionEventType { create, find, begin }

@immutable
class LocalSessionEvent extends SessionEvent {
  LocalSessionEvent({required this.socket, required this.type, this.sessionId = ''});

  final socket_io.Socket socket;
  final LocalSessionEventType type;
  final String sessionId;
}
