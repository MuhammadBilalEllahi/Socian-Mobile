class ApiConstants {
  // static const String baseUrl = "http://192.168.1.7:8080"; //my ip address
  // static const String baseUrl = "http://192.168.10.6:8080"; //my ip address
  // static const String baseUrl = "http://localhost:8080"; //my ip address
  
  // This below is ort forwarding url from localhost:8080. create your own every time
  static const String baseUrl = "https://backend.beyondtheclass.bilalellahi.com";



  static const String api = '/api';

  static const String uploads = '/uploads';
  static const String pdfBaseURl = "$baseUrl$api$uploads/";


static const String auth = '/auth';
  static const String loginEndpoint = "$api$auth/login";
  static const String registerEndpoint = "$api$auth/register";
  static const String registerVerifyEndpoint = "$api$auth/registration-verify-otp";

  


  static const String accessible = '/accessible';
  static const String apiAccessible = '$api$accessible';
  static const String universityAndCampusNames = '$apiAccessible/universities/grouped/campus';
  static const String usernames = '$apiAccessible/usernames';


  static const String pastpaper = '/pastpaper';
  // static const String subjectPastpapers = '$api$pastpaper/all-pastpapers-in-subject/67839bd37b4bcea6d564a5f8';
  static const String subjectPastpapers = '$api$pastpaper/all-pastpapers-in-subject';



  static const String department = '/department';
  static const String campus = '$api$department/campus';


  static const String posts = '/posts';
  static const String postsCampus = '$api$posts/campus/all';




}

class AppConstants {
  static const String appName = "Beyond The Class";
  static const String appSlogan = "Discover New Horizons, Look Beyond the Class";
  static const String appSloganNewLine = "Discover New Horizons \nLook Beyond the Class";
  static const String appGreeting ="Good Day";
}



class AppRoutes {
  static const String authScreen = "/auth";
  static const String signupScreenStudent = '/register/student' ;
  static const String  login='/login';


  static const String postMainPage = '/postsMain';
static const String messagesMainPage = '/msgMain';
static const String mapMainPage = '/mapMain';
static const String profileMainPage = '/profMain';



  static const String  home='/';
  static const String  splashScreen='/splash';
  static const String  roleSelection='/select/role';
  static const String  otpScreen='/otp';
    static const String  pastPaperScreen='/pastpaper';

}