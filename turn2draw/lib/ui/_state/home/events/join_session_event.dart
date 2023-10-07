part of '../home_event.dart';

class JoinSessionEvent extends HomeEvent {
  JoinSessionEvent({this.sessionCode});

  final String? sessionCode;
}
