import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
import 'package:beyondtheclass/features/auth/presentation/student_signupScreen.dart';
import 'package:beyondtheclass/features/auth/presentation/widgets/RoleSelectionPage.dart';
import 'package:beyondtheclass/features/auth/presentation/widgets/login_form.dart';
import 'package:beyondtheclass/features/auth/presentation/widgets/otp_form.dart';
import 'package:beyondtheclass/pages/splashScreen/SplashScreen.dart';
import 'package:beyondtheclass/pages/drawer/pages/pastPaper/PastPapers.dart';
import 'package:beyondtheclass/pages/explore/MapsPage.dart';
import 'package:beyondtheclass/pages/home/HomePage.dart';
import 'package:beyondtheclass/pages/home/widgets/PostsPrimaryPage.dart';
import 'package:beyondtheclass/pages/message/Messages.dart';
import 'package:beyondtheclass/pages/profile/ProfilePage.dart';
import 'package:beyondtheclass/theme/AppThemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async{

   
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      themeMode: ThemeMode.system,
      theme: AppThemes.lightTheme, // Use light theme
      // theme: AppThemes.darkTheme, // Use light theme
      darkTheme: AppThemes.darkTheme, // Use dark theme
      initialRoute:
          AppRoutes.splashScreen,
      routes: {
        // USE THIS INSTEAD OF THAT REDUNDANT SOOOOOO MUCH CODE
        AppRoutes.splashScreen: (context) => const SplashScreen(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.authScreen: (context) => const AuthScreen(),
        AppRoutes.login: (context) => const LoginForm(),
        AppRoutes.signupScreenStudent: (context) => const SignUpScreen(),

        // AppRoutes.postMainPage: (context) => const PostsPrimaryPage(),
        AppRoutes.messagesMainPage: (context) => const Messages(),
        AppRoutes.mapMainPage: (context) => const MapsLook(),
        AppRoutes.profileMainPage: (context) => const ProfilePage(),

        AppRoutes.roleSelection: (context) => const RoleSelectionPage(),
        AppRoutes.otpScreen: (context) => const OTPVerificationScreen(),
        AppRoutes.pastPaperScreen : (context)=> const PastPapers()

      },
    );
  }
}
