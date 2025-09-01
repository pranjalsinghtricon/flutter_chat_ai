import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue, //for text
      primaryFixed: Colors.black87, // for normal text
      primaryContainer: Colors.black54, //for text
      secondary: Colors.black87, // for text in-front of icon
      tertiary: Colors.black87,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black54, // for icon colors
      outline: Color(0xFFDDDDDD),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: Color(0xFF444444),
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );
}
