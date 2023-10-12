part of '../session_event.dart';

enum PlayerSocketEventType {
  kick,
}

class PlayerSocketEvent extends SessionEvent {
  PlayerSocketEvent({required this.socket, required this.player, this.type = PlayerSocketEventType.kick});

  final socket_io.Socket socket;
  final PlayerSocketEventType type;
  final Player player;
}
