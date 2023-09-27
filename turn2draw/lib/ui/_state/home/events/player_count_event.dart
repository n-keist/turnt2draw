part of '../home_event.dart';

enum CountEventType {
  add,
  remove;
}

enum CountSubject {
  turnDuration,
  roundCount,
  playerCount;
}

class ChangeCountOnSubjectEvent extends HomeEvent {
  final CountEventType type;
  final CountSubject subject;

  ChangeCountOnSubjectEvent({required this.type, required this.subject});
}
