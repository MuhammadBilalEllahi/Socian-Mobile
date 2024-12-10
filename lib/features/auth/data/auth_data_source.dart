abstract class AuthDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
}



// import 'auth_repo.dart';

// class AuthDataSource {
//   final AuthRepo authRepo;

//   AuthDataSource(this.authRepo);

//   Future<Map<String, dynamic>> login(String email, String password) {
//     return authRepo.login(email, password);
//   }
// }





