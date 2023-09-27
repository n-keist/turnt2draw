part of '../home_event.dart';

class JoinSessionEvent extends HomeEvent {
  JoinSessionEvent({this.sessionId = ''});

  final String sessionId;
}
