import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  const Settings({this.hapticFeedback = false});

  final bool hapticFeedback;

  @override
  List<Object?> get props => [hapticFeedback];
}
