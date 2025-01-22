class ApiConstants {
  static const String baseUrl = "http://192.168.1.3:8080"; //my ip address

  // This below is ort forwarding url from localhost:8080. create your own every time
  // static const String baseUrl = "https://backend.beyondtheclass.bilalellahi.com";

  static const String api = '/api';


static const String auth = '/auth';
  static const String loginEndpoint = "$api$auth/login";
  static const String registerEndpoint = "$api$auth/register";
  static const String registerVerifyEndpoint = "$api$auth/registration-verify-otp";

  


  static const String accessible = '/accessible';
  static const String universityAndCampusNames = '$api$accessible/universities/grouped/campus';
  static const String usernames = '$api$accessible/usernames';


}

class AppConstants {
  static const String appName = "Beyond The Class";
  static const String appSlogan = "Discover New Horizons, Look Beyond the Class";
  static const String appGreeting ="Good Day, User!";
}