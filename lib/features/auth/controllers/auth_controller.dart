
import 'package:beyondtheclass/features/auth/domain/auth_usecase.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthUseCases authUseCases;

  AuthController({required this.authUseCases}) : super(const AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await SecureStorageService.instance.getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final user = JwtDecoder.decode(token);
      state = state.copyWith(user: user, token: token);
    }
  }

  Future<void> logout() async {
    await SecureStorageService.instance.deleteToken();
    state = const AuthState(); // Reset state
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await authUseCases.login(email, password);
      final token = response['access_token'];
      final user = JwtDecoder.decode(token);
      if (user.isNotEmpty) {
        state = state.copyWith(user: user, token: token, isLoading: false, error: null);
        await SecureStorageService.instance.saveToken(token);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// import 'dart:convert';

// import 'package:beyondtheclass/features/auth/domain/auth_usecase.dart';
// import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
// import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';


// class AuthController extends StateNotifier<AuthState> {
//   final AuthUseCases authUseCases;

//   AuthController({required this.authUseCases}) : super(const AuthState());

//   Future<void> login(String email, String password) async {
//     print(
//         "2 - File: auth_controller.dart - This is credentials: $email and $password");

//     state = state.copyWith(isLoading: true);

//     try {
//       final response = await authUseCases.login(email, password);

//       print("cameback here $response");

//       final token = response['token'];
//       print("token here $token");

//       // String yourToken = "";
//       Map<String, dynamic> user = JwtDecoder.decode(token);

//       // final user = jsonDecode(token);
// //       print("\n\n\n user here $user");

//       if(user.isNotEmpty){
//           state = state.copyWith(user: user, token: token,isLoading: false, error: null);
//           SecureStorageService.instance.saveToken(token);
//       }
      
//     } catch (e) {
//       state = state.copyWith(
//         error: e.toString(),
//         isLoading: false,
//       );
//     }
//   }
// }





