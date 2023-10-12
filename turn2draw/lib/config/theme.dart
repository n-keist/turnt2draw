import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final lightTheme = ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    foregroundColor: Colors.grey.shade800,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: TextStyle(
      color: Colors.grey.shade800,
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    elevation: 0.0,
  ),
  splashFactory: NoSplash.splashFactory,
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(
      elevation: MaterialStatePropertyAll(0),
      overlayColor: MaterialStatePropertyAll(Colors.transparent),
    ),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
);
