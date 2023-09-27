import 'package:flutter/material.dart';
import 'package:turn2draw/config/theme.dart';
import 'package:turn2draw/router.dart';

class DrawApp extends StatelessWidget {
  const DrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: lightTheme,
      routerConfig: router,
    );
  }
}
