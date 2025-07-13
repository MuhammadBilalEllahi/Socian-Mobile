import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:socian/shared/services/WebSocketService.dart';
import 'package:socian/shared/services/shared_preferences.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:socian/shared/utils/route_guard.dart';
import 'package:socian/theme/AppThemes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await WebSocketService().connect();
  await MobileAds.instance.initialize();
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final androidId = androidInfo.id;
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ['69B5A27736A2F4EFB67F6E96D9D24EEF'],
    ),
  );

  MobileAds.instance.setAppMuted(true);

  // final config = PostHogConfig(dotenv.env['POSTHOG_API'] ?? '');
  // config.debug = true;
  // config.captureApplicationLifecycleEvents = true;
  // config.host = dotenv.env['POSTHOG_HOST'] ?? '';
  // await Posthog().setup(config);
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
      // navigatorObservers: [
      //   // The PosthogObserver records screen views automatically
      //   PosthogObserver(),
      // ],
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
