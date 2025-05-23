import 'package:socian/shared/services/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/core/utils/route_guard.dart';
import 'package:socian/theme/AppThemes.dart';
import 'package:socian/shared/services/WebSocketService.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
 await WebSocketService().connect();
   await MobileAds.instance.initialize();

  await AppPrefs.init();
  await IntroStatus.initializeFromCache();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateRoute: (settings) => RouteGuard.onGenerateRoute(settings, ref),
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      themeMode: ThemeMode.system,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      initialRoute: AppRoutes.splashScreen,
    );
  }
}
