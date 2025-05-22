import 'package:socian/features/auth/data/auth_data_source.dart';

class AuthUseCases {
  final AuthDataSource authDataSource;

  AuthUseCases(this.authDataSource);

  Future<Map<String, dynamic>> login(String email, String password) async {
        print("3 - File: auth_usecase.dart - This is credentials: $email and $password");

    return await authDataSource.login(email, password);
  }
}

// after oldest
// import 'package:socian/features/auth/data/auth_data_source.dart';

// class AuthUseCases {
//   final AuthDataSource authDataSource;

//   AuthUseCases(this.authDataSource);

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     return await authDataSource.login(email, password);
//   }
// }



// Oldest below

// import '../repositories/auth_repository_impl.dart';

// class LoginUser {
//   final AuthRepo repository;

//   LoginUser({required this.repository});

//   Future<Map<String, dynamic>> call(String email, String password) {
//     return repository.login(email, password);
//   }
// }

// class RegisterUser {
//   final AuthRepo repository;

//   RegisterUser({required this.repository});

//   Future<void> call(String universityEmail, String password) async {
//     // Add registration logic here
//     throw UnimplementedError(); // Implement as needed
//   }
// }

// class AuthUseCases {
//   final LoginUser loginUser;
//   final RegisterUser registerUser;

//   AuthUseCases({
//     required this.loginUser,
//     required this.registerUser,
//   });
// }
