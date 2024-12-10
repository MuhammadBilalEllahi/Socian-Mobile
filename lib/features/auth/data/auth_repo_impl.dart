import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/features/auth/data/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final ApiClient apiClient;

  AuthRepoImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    print("5 - File: auth_repo_impl.dart - This is credentials: $email and $password");

    final response = await apiClient.post(
      '/api/auth/login',
      {"email": email, "password": password},
    );
    return response;
  }
}


// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';

// import 'auth_repo.dart';

// class AuthRepoImpl implements AuthRepo {
//   final ApiClient apiClient;

//   AuthRepoImpl(this.apiClient);

//   @override
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final response = await apiClient.post(
//       ApiConstants.loginEndpoint,
//       {"email": email, "password": password},
//     );
//     return response;
//   }
// }
