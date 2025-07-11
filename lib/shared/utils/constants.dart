import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socian/shared/services/shared_preferences.dart';

class ApiConstants {
  // static const String localhostBaseUrl =
  //     "http://10.135.49.240:8080"; //my ip address
  // // static const String baseUrl = "http://192.168.10.6:8080"; //my ip address
  // static const String productionBaseUrl =
  //     "https://api.socian.me"; //my ip address

  // This below is ort forwarding url from localhost:8080. create your own every time

  static Map<int, String> urlMap = {
    -4: "http://10.135.58.129:8080", // localhost
    -3: 'https://j9kfnb6c-8080.inc1.devtunnels.ms', //bilal
    -2: 'https://w7x50p90-8080.inc1.devtunnels.ms', //rayyan
    -1: "http://10.135.58.129:8080", // localhost
    0: "https://api.socian.app", // production

    1: "http://192.168.1.1:8080",
    2: "http://192.168.1.2:8080",
    3: "http://192.168.1.3:8080",
    10: "http://192.168.1.10:8080",
    4: "http://192.168.1.4:8080",
    5: "http://192.168.1.5:8080",
    6: "http://192.168.1.6:8080",
    7: "http://192.168.1.7:8080",
    8: "http://192.168.1.8:8080",
    9: "http://192.168.1.9:8080",
    12: "http://192.168.1.12:8080",
    11: "http://192.168.1.11:8080",
    90: "http://10.135.48.250:8080",
    100: "http://10.135.55.56:8080",
    111: "http://10.135.54.210:8080"
  };

  static int _currentUrlIndex = 6;
  static const String _urlIndexCacheKey = 'current_url_index';

  static Future<void> initializeBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUrlIndex = prefs.getInt(_urlIndexCacheKey) ?? 0;
  }

  static Future<void> _saveUrlPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_urlIndexCacheKey, _currentUrlIndex);
  }

  static Future<void> setUrlByIndex(int index) async {
    if (urlMap.containsKey(index)) {
      _currentUrlIndex = index;
      await _saveUrlPreference();
    }
  }

  static String get baseUrl {
    if (kReleaseMode) {
      return urlMap[0]!; // Always use production URL in release mode
    }
    return urlMap[_currentUrlIndex] ?? urlMap[0]!;
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
  static const String uploadProfilePic = '/api/user/update/picture';

  static const String pastpaper = '/pastpaper';
  // static const String subjectPastpapers = '$api$pastpaper/all-pastpapers-in-subject/67839bd37b4bcea6d564a5f8';
  static const String subjectPastpapers =
      '$api$pastpaper/all-pastpapers-in-subject';

  static const String department = '/department';
  static const String campus = '$api$department/campus';

  static const String posts = '/posts';
  static const String postsCampus = '$api$posts/campus/all';
  static const String intraCampusPosts = '$api$posts/campuses/all';
  static const String universiyPosts = '$api$posts/universities/all';

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

  static const String privacyPolicy = '/privacy-policy';

  // Student routes
  static const String home = '/home';
  static const String messagesMainPage = '/messages';
  static const String mapMainPage = '/map';
  static const String profileMainPage = '/profile';
  static const String pastPaperScreen = '/past-papers';

  static const String departmentScreen = '/department-screen';
  static const String subjectsInDepartmentScreen = '/subjects-in-department';
  static const String discussionViewScreen = '/discussion-view';
  static const String settings = '/settings';
  static const String answersPage = '/past-paper/answers';
  static const String scheduleGatherings = '/scheduled-gatherings';
  static const String teacherReviewPage = '/teacher-review';
  static const String cafeReviewsHome = '/cafe-reviews-page';
  static const String intraCampus = '/intra-campus';
  static const String personalInfoEditScreen = '/personal-info/edit';

  // Teacher routes
  static const String teacherHome = '/teacher/home';
  static const String teacherProfile = '/teacher/profile';
  static const String teacherFeedbacks = '/teacher/feedbacks';
  static const String selfReviewTeacher = '/teacher/self/reviews';

  // Alumni routes
  static const String alumniHome = '/alumni/home';
  static const String alumniProfile = '/alumni/profile';
  static const String alumniJobs = '/alumni/jobs';
  static const String alumniScrolls = '/alumni/scrolls';
  static const String jobProfile = '/alumni/job/profile';

  static const String alumniUploadCard = '/alumni/verif/card';
  static const String alumniLivePicture = '/alumni/verif/live-picture';
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

enum EnumVoteType { upvote, downvote }

enum IntroStatusEnum { pastpaperRightNaviagation, skip, allCompleted }

class IntroStatus {
  static const _prefix = 'introStatus_';
  static String _keyFor(IntroStatusEnum status) => '$_prefix${status.name}';

  static final Map<IntroStatusEnum, bool> introStatus = {
    IntroStatusEnum.pastpaperRightNaviagation: false,
    IntroStatusEnum.skip: false,
    IntroStatusEnum.allCompleted: false
  };

  static final Map<IntroStatusEnum, bool> _introStatus = {
    for (var status in IntroStatusEnum.values) status: false,
  };

  static Future<void> initializeFromCache() async {
    final prefs = AppPrefs();
    for (var status in IntroStatusEnum.values) {
      final key = _keyFor(status);
      final value = prefs.getBool(key) ?? false;
      _introStatus[status] = value;
    }
  }

  static isAllIntroCompleteOrSkipped() {
    return _introStatus[IntroStatusEnum.skip] == true ||
        _introStatus[IntroStatusEnum.allCompleted] == true;
  }

  static bool getStatus(IntroStatusEnum status) {
    return _introStatus[status] ?? false;
  }

  static isThisIntroCompleted(IntroStatusEnum statusEnum) {
    return _introStatus[statusEnum] == true;
  }

  static Future<void> markIntroCompleted(
      IntroStatusEnum introStatusEmun) async {
    _introStatus[introStatusEmun] = true;
    final prefs = AppPrefs();
    await prefs.setBool(_keyFor(introStatusEmun), true);
  }
}

enum Flairs {
  university(0),
  campus(1),
  department(2);

  final int value;
  const Flairs(this.value);
}

enum RiveThumb {
  swipeRight,
  swipeLeft,
  oneTouch,
  forceTouch,
  tapAndHold,
  tap3,
  tap2,
  tap,
  doubleTap,
  idle
}

class RiveComponentStrings {
  static const Map<RiveThumb, String> thumbAnimations = {
    RiveThumb.swipeRight: 'Swipe Right',
    RiveThumb.swipeLeft: 'Swipe Left',
    RiveThumb.oneTouch: '1 Touch',
    RiveThumb.forceTouch: 'Force Touch',
    RiveThumb.tapAndHold: 'Tap & Hold',
    RiveThumb.tap3: 'Tap 3',
    RiveThumb.tap2: 'Tap 2',
    RiveThumb.tap: 'Tap',
    RiveThumb.doubleTap: 'Double Tap',
    RiveThumb.idle: 'Idle',
  };

  static const String thumbAsset = 'assets/animations/thumbsList.riv';
}



// class BottomNavBarRouteMap {
//   static const int  home=0;
//   static const int  message=1;
//   static const int  search=2;
//   static const int  explore=3;
//     static const int  profile=4;
// }