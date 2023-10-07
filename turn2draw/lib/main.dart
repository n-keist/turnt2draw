import 'package:flutter/material.dart';
import 'package:turn2draw/app.dart';
import 'package:turn2draw/locator.dart';

void main() {
  setupLocator().then((_) {
    runApp(
      const DrawApp(),
    );
  });
}
