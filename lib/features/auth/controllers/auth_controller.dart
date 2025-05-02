import 'package:beyondtheclass/features/auth/domain/auth_usecase.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:beyondtheclass/core/utils/constants.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthUseCases authUseCases;
  bool _isDisposed = false;

  AuthController({required this.authUseCases})
      : super(const AuthState(isLoading: true)) {
    // Initialize token loading after the widget tree is built
    Future.microtask(() => _loadToken());
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  bool get mounted => !_isDisposed;

  Future<void> _loadToken() async {
    if (!mounted) return;
    try {
      final token = await SecureStorageService.instance.getToken();
      if (!mounted) return;

      if (token != null && !JwtDecoder.isExpired(token)) {
        final user = JwtDecoder.decode(token);
        if (!mounted) return;
        state = state.copyWith(
          user: user,
          token: token,
          role: user['role'] ?? AppRoles.student,
          isLoading: false,
        );
      } else {
        // If token is expired or invalid, clear it
        await SecureStorageService.instance.deleteToken();
        if (!mounted) return;
        state = const AuthState(isLoading: false);
      }
    } catch (e) {
      // If there's any error loading the token, clear it
      await SecureStorageService.instance.deleteToken();
      if (!mounted) return;
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> logout() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    await SecureStorageService.instance.deleteToken();
    if (!mounted) return;
    state = const AuthState(isLoading: false);
  }

  Future<void> login(String email, String password) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      final response = await authUseCases.login(email, password);
      if (!mounted) return;

      final token = response['access_token'];
      final user = JwtDecoder.decode(token);
      if (user.isNotEmpty && mounted) {
        state = state.copyWith(
          user: user,
          token: token,
          role: user['role'] ?? AppRoles.student,
          isLoading: false,
        );
        await SecureStorageService.instance.saveToken(token);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateAuthState(Map<String, dynamic> user, String token) async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    try {
      await SecureStorageService.instance.saveToken(token);
      if (!mounted) return;
      state = state.copyWith(
          user: user,
          token: token,
          isLoading: false,
          error: null,
          role: user['role'] ?? AppRoles.student);
    } catch (e) {
      if (!mounted) return;
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





