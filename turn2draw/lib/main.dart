import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turn2draw/app.dart';
import 'package:turn2draw/data/repository/word_repository.dart';
import 'package:turn2draw/locator.dart';
import 'package:turn2draw/storage/local_storage.dart';

void main() {
  setupLocator().then((_) {
    runApp(
      MultiRepositoryProvider(
        providers: <RepositoryProvider>[
          RepositoryProvider<WordRepository>(
            create: (context) => WordRepository(
              storage: locator<LocalStorage>(),
            ),
          ),
        ],
        child: const DrawApp(),
      ),
    );
  });
}
