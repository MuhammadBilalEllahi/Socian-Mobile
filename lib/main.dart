import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'UI Pages/SplashScreen.dart';
import 'package:flutter/material.dart';

import 'UI Pages/AppThemes.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}





class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      themeMode: ThemeMode.system,
      theme: AppThemes.lightTheme, // Use light theme
      darkTheme: AppThemes.darkTheme, // Use dark theme
      home: const SplashScreen(),
    );
  }
}


