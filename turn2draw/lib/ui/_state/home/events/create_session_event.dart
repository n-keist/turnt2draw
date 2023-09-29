part of '../home_event.dart';

class CreateSessionEvent extends HomeEvent {
  CreateSessionEvent({this.config = const CreateSessionConfig()});

  final CreateSessionConfig config;
}
