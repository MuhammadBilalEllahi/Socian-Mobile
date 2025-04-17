import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  static const String localhostBaseUrl =
      "http://10.135.49.240:8080"; //my ip address
  // static const String baseUrl = "http://192.168.10.6:8080"; //my ip address
  static const String productionBaseUrl =
      "https://api.beyondtheclass.me"; //my ip address

  // This below is ort forwarding url from localhost:8080. create your own every time

  // static String get baseUrl => dotenv.env['PRODUCTION'] == "true"
  //     ?
  //     : localhostBaseUrl;

  static bool _useProductionUrl = false;
  static const String _baseUrlCacheKey = 'use_production_url';

  static Future<void> initializeBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _useProductionUrl = prefs.getBool(_baseUrlCacheKey) ?? false;
  }

  static Future<void> _saveUrlPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_baseUrlCacheKey, _useProductionUrl);
  }

  static Future<void> toggleBaseUrl() async {
    _useProductionUrl = !_useProductionUrl;
    await _saveUrlPreference();
  }

  static String get baseUrl {
    if (kReleaseMode) {
      return productionBaseUrl; // Always use production URL in release mode
    }
    return _useProductionUrl ? productionBaseUrl : localhostBaseUrl;
  }

  static const String api = '/api';

  static const String uploads = '/uploads';
  static String get pdfBaseURl => "$baseUrl$api$uploads/";

  static const String auth = '/auth';
  static const String loginEndpoint = "$api$auth/login";
  static const String registerEndpoint = "$api$auth/register";
  static const String registerVerifyEndpoint =
      "$api$auth/registration-verify-otp";

  static const String accessible = '/accessible';
  static const String apiAccessible = '$api$accessible';
  static const String universityAndCampusNames =
      '$apiAccessible/universities/grouped/campus';
  static const String usernames = '$apiAccessible/usernames';

  static const String pastpaper = '/pastpaper';
  // static const String subjectPastpapers = '$api$pastpaper/all-pastpapers-in-subject/67839bd37b4bcea6d564a5f8';
  static const String subjectPastpapers =
      '$api$pastpaper/all-pastpapers-in-subject';

  static const String department = '/department';
  static const String campus = '$api$department/campus';

  static const String posts = '/posts';
  static const String postsCampus = '$api$posts/campus/all';

  static const String users = '/users';
  static const String searchUsers = '$api$users/search';

  static const String teachers = '/teacher';
  static const String campusTeachers = '$api$teachers/campus/teachers';
}

class AppConstants {
  static const String appName = "Beyond The Class";
  static const String appSlogan =
      "Discover New Horizons, Look Beyond the Class";
  static const String appSloganNewLine =
      "Discover New Horizons \nLook Beyond the Class";
  static const String appGreeting = "Good Day";

  static const String login = "Login";

  static const String signUp = "Sign Up";

  static const String googleAuth = "Continue with Google";
}

class AppRoles {
  static const String teacher = "teacher";
  static const String student = "student";
  static const String alumni = "alumni";
  static const String extOrg = "ext_org";
  static const String noAccess = "no_access";
}

class AppSuperRoles {
  static const String superAdmin = "super";
  static const String admin = "admin";
  static const String moderator = "mod";
  // static const String none = "none";
}

class AppRoutes {
  // Auth routes
  static const String splashScreen = '/';
  static const String authScreen = '/auth';
  static const String login = '/login';
  static const String signupScreen = '/signup';
  static const String roleSelection = '/role-selection';
  static const String otpScreen = '/otp';

  // Student routes
  static const String home = '/home';
  static const String messagesMainPage = '/messages';
  static const String mapMainPage = '/map';
  static const String profileMainPage = '/profile';
  static const String pastPaperScreen = '/past-papers';
  static const String subjectsInDepartmentScreen = '/subjects-in-department';
  static const String discussionViewScreen = '/discussion-view';
  static const String settings = '/settings';
  static const String answersPage = '/past-paper/answers';

  // Teacher routes
  static const String teacherHome = '/teacher/home';
  static const String teacherProfile = '/teacher/profile';
  static const String teacherFeedbacks = '/teacher/feedbacks';

  // Alumni routes
  static const String alumniHome = '/alumni/home';
  static const String alumniProfile = '/alumni/profile';
  static const String alumniJobs = '/alumni/jobs';
}

class AppAssets {
  static const String splashBackground2 = 'assets/images/bg-splash2.jpg';
  static const String anime = 'assets/images/anime.png';
  static const String profilePic = 'assets/images/profilepic.jpg';
  static const String googleAuth = 'assets/images/googleAuth.png';
}

enum BottomNavBarRoute { home, message, explore, gps, profile }

extension BottomNavBarRouteMap on BottomNavBarRoute {
  int get index => BottomNavBarRoute.values.indexOf(this);
}



// class BottomNavBarRouteMap {
//   static const int  home=0;
//   static const int  message=1;
//   static const int  search=2;
//   static const int  explore=3;
//     static const int  profile=4;
// }