import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final lightTheme = ThemeData(
  fontFamily: 'ComingSoon',
  applyElevationOverlayColor: true,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    foregroundColor: Colors.grey.shade800,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: TextStyle(
      fontFamily: 'ComingSoon',
      color: Colors.grey.shade800,
      fontWeight: FontWeight.bold,
      fontSize: 24.0,
      decoration: TextDecoration.underline,
      decorationThickness: 1.75,
      decorationStyle: TextDecorationStyle.wavy,
    ),
  ),
);
