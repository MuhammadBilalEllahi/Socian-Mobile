import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'UI Pages/SplashScreen.dart';
import 'package:flutter/material.dart';

import 'UI Pages/AppThemes.dart';
import 'features/auth/presentation/auth_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beyond The Class',
      themeMode: ThemeMode.system,
      theme: AppThemes.lightTheme, // Use light theme
      darkTheme: AppThemes.darkTheme, // Use dark theme
      home: const SplashScreen(),
    );
  }
}


