part of '../session_event.dart';

class SocketSessionEvent extends SessionEvent {
  SocketSessionEvent({required this.socket, required this.event, this.payload});

  final socket_io.Socket socket;
  final String event;
  final Map<String, dynamic>? payload;
}
