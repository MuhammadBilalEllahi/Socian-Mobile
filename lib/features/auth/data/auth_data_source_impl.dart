import 'package:flutter/foundation.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/features/auth/data/auth_data_source.dart';
// import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
// import 'package:beyondtheclass/shared/services/secure_storage_service.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final ApiClient client;

  AuthDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    print(
        "4 - File: auth_data_source_impl.dart - This is credentials: $email and $password");

    try {
      // Adding a print to check the API call
      debugPrint(
          "4.1 - Making API call to login endpoint ${ApiConstants.baseUrl}");

      final response = await client.post(
        ApiConstants.loginEndpoint,
        {'email': email, 'password': password},
        // headers: {"x-platform": "app"},
      );

      // Check the response status
      print("4.2 - API call response: ${response.toString()}");

      if (response.containsKey('access_token')) {
        String token = response['access_token'];

        // await SecureStorageService.instance.saveToken(token);
        // await  SharedPreferencesService.instance.saveToken(token);
        print("Token received: $token");

        return {'access_token': token};
      } else {
        throw Exception('No token received');
      }
      // return response;
    } catch (e) {
      // Catching any errors and logging them
      print("4.3 - Error in API call: $e");
      rethrow;
    }
// Assuming response is already a Map
  }
}


// final prefs = await SharedPreferences.getInstance();
// prefs.setString('auth_token', token);

// authController.updateLoginState(token);

// final jwt = JWT.decode(token);
// print(jwt['userId']);



// import 'package:beyondtheclass/features/auth/data/auth_data_source.dart';
// import 'package:beyondtheclass/features/auth/data/auth_repo.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';

// class AuthDataSourceImpl implements AuthDataSource {
//   final ApiClient client;

//   AuthDataSourceImpl({required this.client});

//   @override
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final response = await client.post(
//       '/api/auth/login',
//       {'email': email, 'password': password},
//       headers: {"x-platform": "app"},
//     );

//     return response ; // Assuming response.data is a Map
//   }

//   @override
//   // TODO: implement authRepo
//   AuthRepo get authRepo => throw UnimplementedError();
// }

