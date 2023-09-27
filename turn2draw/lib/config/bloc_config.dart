import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/config/logger.dart';

class DrawAppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    logger.d('BLOC-CREATE: ${bloc.runtimeType.toString()}');
    super.onCreate(bloc);
  }

  @override
  void onClose(BlocBase bloc) {
    logger.d('BLOC-CLOSE: ${bloc.runtimeType.toString()}');
    super.onClose(bloc);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    logger.d('BLOC-ERROR: ${bloc.runtimeType.toString()}', stackTrace: stackTrace, error: error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    logger.d('BLOC-EVENT: ${event.runtimeType.toString()} -> ${bloc.runtimeType.toString()}');
    super.onEvent(bloc, event);
  }
}
