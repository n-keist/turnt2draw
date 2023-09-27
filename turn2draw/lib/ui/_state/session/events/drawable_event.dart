part of '../session_event.dart';

enum DrawableEventType { create, update, commit }

@immutable
class DrawableSessionEvent extends SessionEvent {
  DrawableSessionEvent({required this.socket, required this.drawable, required this.eventType});

  final socket_io.Socket socket;
  final PaintDrawable drawable;
  final DrawableEventType eventType;
}
