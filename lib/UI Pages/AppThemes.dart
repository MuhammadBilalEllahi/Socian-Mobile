import 'package:flutter/material.dart';

class AppThemes{
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // Customize other light theme properties as needed
    // primaryColor: Colors.greenAccent,
    scaffoldBackgroundColor: Colors.white,
    // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    //   backgroundColor: Colors.blue,
    //
    // ),
    textTheme: const TextTheme(
      // bodyText1: TextStyle(color: Colors.black),
      // bodyText2: TextStyle(color: Colors.black),
    ),
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(surface: Colors.white),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    // useMaterial3: true,
    brightness: Brightness.dark,
    // // Customize other dark theme properties as needed
    // primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.indigo[900],
    // textTheme: const TextTheme(
    //   // bodyText1: TextStyle(color: Colors.white),
    //   // bodyText2: TextStyle(color: Colors.white),
    // ), colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(surface: Colors.black),
  );
}