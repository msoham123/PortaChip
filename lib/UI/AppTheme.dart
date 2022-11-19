import 'package:flutter/material.dart';

class AppTheme {
  //The theme of our app

  static final List<ThemeData> themes = [light, dark];

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.pink,
        backgroundColor: Colors.white,
        accentColor: Colors.pinkAccent),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: Colors.black,
        fontSize: 13,
      ),
      headlineMedium: TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),
      headlineLarge: TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.black45,
        accentColor: Colors.blueAccent),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 15,
      ),
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
