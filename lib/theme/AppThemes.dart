import 'package:flutter/material.dart';

class AppThemes {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F4F5),
    textTheme: const TextTheme(),
    iconTheme: const IconThemeData(
      color: Color(0xFF18181B),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF18181B),
      onPrimary: Color(0xFFF4F4F5),
      secondary: Color(0xFF4F46E5),
      onSecondary: Color(0xFFF4F4F5),
      error: Color(0xFFEF4444),
      onError: Color(0xFFF4F4F5),
      surface: Colors.white,
      onSurface: Color(0xFF18181B),
    ),
    dividerColor: const Color(0xFFE5E7EB),
    hintColor: const Color(0xFF6B7280),
    cardColor: Colors.white,
    highlightColor: const Color(0xFFFAFAFA),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF18181B),
    textTheme: const TextTheme(),
    iconTheme: const IconThemeData(
      color: Color(0xFFF4F4F5),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF4F4F5),
      onPrimary: Color(0xFF18181B),
      secondary: Color(0xFF6366F1),
      onSecondary: Color(0xFF18181B),
      error: Color(0xFFEF4444),
      onError: Color(0xFF18181B),
      surface: Color(0xFF232326),
      onSurface: Color(0xFFF4F4F5),
    ),
    dividerColor: const Color(0xFF27272A),
    hintColor: const Color(0xFF71717A),
    cardColor: const Color(0xFF232326),
    highlightColor: const Color(0xFF27272A),
  );
}
