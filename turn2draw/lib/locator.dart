import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn2draw/config/bloc_config.dart';
import 'package:turn2draw/data/service/impl/local_player_service.dart';
import 'package:turn2draw/data/service/impl/remote_session_service.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:turn2draw/firebase_options.dart';
import 'package:turn2draw/storage/impl/shared_preferences_local_storage.dart';
import 'package:turn2draw/storage/local_storage.dart';

final locator = GetIt.I;

Future<void> setupLocator() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = DrawAppBlocObserver();

  final preferences = await SharedPreferences.getInstance();

  if (kDebugMode) {
    await preferences.clear();
  }

  final localStorage = SharedPreferencesLocalStorage(preferences: preferences);

  locator.registerSingleton<LocalStorage>(localStorage);

  locator.registerSingleton<PlayerService>(
    LocalPlayerService(
      localStorage: localStorage,
    ),
  );

  locator.registerSingleton<SessionService>(
    RemoteSessionService(),
  );

  await locator.allReady();
}
