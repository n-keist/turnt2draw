part of '../home_event.dart';

enum PlayerEventType {
  regenerateUsername,
}

class PlayerEvent extends HomeEvent {
  PlayerEvent({this.type = PlayerEventType.regenerateUsername});

  final PlayerEventType type;
}
