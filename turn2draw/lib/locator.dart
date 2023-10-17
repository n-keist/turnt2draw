import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn2draw/config/bloc_config.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/data/service/firebase_service.dart';
import 'package:turn2draw/data/service/impl/firebase_service_impl.dart';
import 'package:turn2draw/data/service/player_service.dart';
import 'package:turn2draw/data/service/session_service.dart';
import 'package:turn2draw/data/service/settings_service.dart';

final locator = GetIt.I;

Future<void> setupLocator() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = DrawAppBlocObserver();

  final preferences = await SharedPreferences.getInstance();

  if (kDebugMode) {
    await preferences.clear();
  }

  if (kReleaseMode && !Platform.environment.containsKey('FLUTTER_TEST')) {
    locator.registerSingleton<FirebaseService>(FirebaseServiceImpl());
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
