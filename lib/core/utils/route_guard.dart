import 'dart:developer';
import 'dart:io';

import 'package:socian/features/auth/presentation/PrivacyPolicyScreen.dart';
import 'package:socian/pages/drawer/student/pages/cafeInformation/CafesHome.dart';
import 'package:socian/pages/drawer/student/pages/pastPaper/DepartmentPage.dart';
import 'package:socian/pages/drawer/student/pages/pastPaper/PastPapers.dart';
import 'package:socian/pages/drawer/student/pages/pastPaper/SubjectsView.dart';
import 'package:socian/pages/drawer/student/pages/pastPaper/discussion/DiscussionView.dart';
import 'package:socian/pages/drawer/student/pages/pastPaper/discussion/answerPage/AnswersPage.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/TeachersPage.dart';
import 'package:socian/pages/drawer/teacher/review/TeacherSelfReview.dart';
import 'package:socian/pages/gps/ScheduledGatherings.dart';
import 'package:socian/pages/home/widgets/intracampus/IntraCampus.dart';
import 'package:socian/pages/profile/settings/personalInfo/PersonalInfoEditPage.dart';
import 'package:socian/shared/services/WebSocketService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/presentation/auth_screen.dart';
import 'package:socian/features/auth/presentation/student_signupScreen.dart';
import 'package:socian/features/auth/presentation/widgets/RoleSelectionPage.dart';
import 'package:socian/features/auth/presentation/widgets/login_form.dart';
import 'package:socian/features/auth/presentation/widgets/otp_form.dart';
import 'package:socian/pages/splashScreen/SplashScreen.dart';
import 'package:socian/pages/home/HomePage.dart';
import 'package:socian/pages/message/Messages.dart';
import 'package:socian/pages/explore/MapsPage.dart';
import 'package:socian/pages/profile/ProfilePage.dart';

import 'package:socian/pages/TeacherMod/TeacherHome.dart';
import 'package:socian/pages/TeacherMod/TeacherProfile.dart';
import 'package:socian/pages/TeacherMod/TeacherFeedbacks.dart';
import 'package:socian/pages/AlumniPages/AlumniHome.dart';
import 'package:socian/pages/AlumniPages/AlumniProfile.dart';
import 'package:socian/pages/AlumniPages/AlumniJobs.dart';
import 'package:socian/pages/profile/settings/SettingsPage.dart';
import 'package:posthog_flutter/posthog_flutter.dart';


void callPostHog(String userId,String name,String email,String role) async{
      await Posthog().identify(
  userId: userId,
  userProperties: {"name": name, "email": email, "role": role},
  userPropertiesSetOnce: {"date_of_first_log_in": DateTime.now().toIso8601String()},
);
}

class RouteGuard {
  static Route<dynamic>? onGenerateRoute(
      RouteSettings settings, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    // debugPrint("The role is ${auth.user}");
    final userRole = auth.user?['role'] ?? '';
    if(userRole != null && auth.user != null) {
      
      WebSocketService().joinNotification(auth.user!['_id']);
callPostHog(
        auth.user!['_id'],
        auth.user!['name'] ?? '',
        auth.user!['email'] ?? '',
        userRole,
      );
    }
    

    // List of routes that don't require authentication
    final publicRoutes = [
      AppRoutes.splashScreen,
      AppRoutes.authScreen,
      AppRoutes.login,
      AppRoutes.signupScreen,
      AppRoutes.roleSelection,
      AppRoutes.otpScreen,
      AppRoutes.privacyPolicy
    ];

    // If trying to access splash screen, always allow it
    if (settings.name == AppRoutes.splashScreen) {
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings,
      );
    }

    // If user is authenticated and trying to access auth routes, redirect to appropriate home
    if (auth.token != null && publicRoutes.contains(settings.name)) {
      return MaterialPageRoute(
        builder: (_) => _getHomePageForRole(userRole),
        settings: RouteSettings(name: _getHomeRouteForRole(userRole)),
      );
    }

    // Allow access to other public routes without authentication
    if (publicRoutes.contains(settings.name)) {
      return MaterialPageRoute(
        builder: (_) => _getPublicRoute(settings.name!),
        settings: settings,
      );
    }

    // If not authenticated and trying to access protected routes, redirect to login
    if (auth.token == null) {
      return MaterialPageRoute(
        builder: (_) => const AuthScreen(),
        settings: const RouteSettings(name: AppRoutes.authScreen),
      );
    }

    // Get the route configuration based on the user's role
    final availableRoutes = _getRoutesForRole(userRole);

    // If the requested route is not available for the user's role, redirect to appropriate home
    if (!availableRoutes.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: (_) => _getHomePageForRole(userRole),
        settings: RouteSettings(name: _getHomeRouteForRole(userRole)),
      );
    }

    // Route is allowed, proceed with navigation
    return MaterialPageRoute(
      builder: (_) => availableRoutes[settings.name]!,
      settings: settings,
    );
  }

  static Widget _getPublicRoute(String routeName) {
    switch (routeName) {
      case AppRoutes.splashScreen:
        return const SplashScreen();
      case AppRoutes.authScreen:
        return const AuthScreen();
      case AppRoutes.login:
        return const LoginForm();
      case AppRoutes.signupScreen:
        return const SignUpScreen();
      case AppRoutes.roleSelection:
        return const RoleSelectionPage();
      case AppRoutes.otpScreen:
        return const OTPVerificationScreen();
      case AppRoutes.privacyPolicy:
        return const PrivacyPolicyScreen();
      default:
        return const AuthScreen();
    }
  }

  static Map<String, Widget> _getRoutesForRole(String? role) {
    final commonRoutes = {
      AppRoutes.settings: const SettingsPage(),
      AppRoutes.cafeReviewsHome: const CafesHome(),
      AppRoutes.intraCampus: const IntraCampus(),
      AppRoutes.pastPaperScreen: const PastPapers(),
      AppRoutes.profileMainPage: const ProfilePage(),
      AppRoutes.departmentScreen: const DepartmentPage(),
      AppRoutes.subjectsInDepartmentScreen: const SubjectsView(),
      AppRoutes.discussionViewScreen: const DiscussionView(),
      AppRoutes.personalInfoEditScreen: const PersonalInfoEditPage()
    };

    switch (role) {
      case AppRoles.student:
        return {
          AppRoutes.home: const HomePage(),
          AppRoutes.messagesMainPage: const Messages(),
          AppRoutes.mapMainPage: const MapsLook(),
          // AppRoutes.profileMainPage: const ProfilePage(),
          // AppRoutes.pastPaperScreen: const PastPapers(),
          // AppRoutes.departmentScreen: const DepartmentPage(),
          // AppRoutes.subjectsInDepartmentScreen: const SubjectsView(),
          // AppRoutes.discussionViewScreen: const DiscussionView(),
          AppRoutes.answersPage: const AnswersPage(),
          AppRoutes.teacherReviewPage: const TeachersPage(),
          AppRoutes.scheduleGatherings: const ScheduledGatherings(),
          // AppRoutes.cafeReviewsHome: const CafesHome(),
          // AppRoutes.intraCampus: const IntraCampus(),
          ...commonRoutes,
        };
      case AppRoles.teacher:
        return {
          AppRoutes.teacherHome: const HomePage(),
          // AppRoutes.teacherProfile: const TeacherProfile(),
          // AppRoutes.teacherFeedbacks: const TeacherFeedbacks(),
          AppRoutes.selfReviewTeacher: const TeacherSelfReview(),
          AppRoutes.teacherReviewPage: const TeachersPage(),
          ...commonRoutes,
        };
      case AppRoles.alumni:
        return {
          AppRoutes.alumniHome: const AlumniHome(),
          AppRoutes.alumniProfile: const AlumniProfile(),
          AppRoutes.alumniJobs: const AlumniJobs(),
          ...commonRoutes,
        };
      default:
        return {};
    }
  }

  static Widget _getHomePageForRole(String? role) {
    switch (role) {
      case AppRoles.student:
        return const HomePage();
      case AppRoles.teacher:
        return const HomePage();
      case AppRoles.alumni:
        return const HomePage();
      default:
        return const AuthScreen();
    }
  }

  static String _getHomeRouteForRole(String? role) {
    switch (role) {
      case AppRoles.student:
        return AppRoutes.home;
      case AppRoles.teacher:
        return AppRoutes.teacherHome;
      case AppRoles.alumni:
        return AppRoutes.alumniHome;
      default:
        return AppRoutes.authScreen;
    }
  }
}
