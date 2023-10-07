import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn2draw/config/bloc_config.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:turn2draw/data/service/settings_service.dart';
import 'package:turn2draw/firebase_options.dart';

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

  locator.registerSingleton<PlayerService>(
    LocalPlayerService(
      preferences: preferences,
    ),
  );

  locator.registerSingleton<SessionService>(
    RemoteSessionService(
      preferences: preferences,
    ),
  );

  locator.registerSingleton<SettingsService>(
    SharedPreferencesSettingsService(
      preferences: preferences,
    )..load(),
    dispose: (service) => service.dispose(),
  );

  locator.registerSingleton<WordRepository>(
    HttpSharedPreferencesWordRepository(
      preferences: preferences,
    ),
  );

  await locator.allReady();
}
