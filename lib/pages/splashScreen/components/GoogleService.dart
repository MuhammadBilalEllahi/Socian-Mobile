// import 'dart:convert';
// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class GoogleSignInService extends StateNotifier<AuthState> {
//   static final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId: '1076027750526-li5gkit9klq06mmocutusfb6ta8e1etc.apps.googleusercontent.com',
//     scopes: ['email', 'profile'],
//   );

//   GoogleSignInService(super.state);



//   static Future<void> signInWithGoogle(BuildContext context) async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return; // User canceled the login

// print("AUTH user ${googleUser.displayName}");
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

// print("AUTH GOOLe $googleAuth");
//       // Extract ID Token from Google Sign-In
//       final String? idToken = googleAuth.idToken;
//       if (idToken == null) {
//         print("Failed to get ID token.");
//         return;
//       }

//       ApiClient apiClient = ApiClient();
// final response = await apiClient.post('${ApiConstants.baseUrl}/api/oauth/google/mobile', {"idToken": idToken});
//       // Send ID Token to Backend
//         print("Login Successful: $response");
//         // Handle successful login (store session, navigate, etc.)
//       String token = response['access_token'];
//       final user = JwtDecoder.decode(token);
//       if (user.isNotEmpty) {
//         state = state.copyWith(user: user, token: token, isLoading: false, error: null);
//         await SecureStorageService.instance.saveToken(token);
//       }
//     } catch (e) {
//       print("Error signing in with Google: $e");
//     }
//   }
// }

import 'dart:convert';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleSignInService extends StateNotifier<AuthState> {
  GoogleSignInService() : super(AuthState.initial());
final googleClientId = dotenv.env['GOOGLE_CLIENT_ID'] ?? "";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: 'googleClientId',
    scopes: ['email', 'profile'],
  );

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return; // User canceled login
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(isLoading: false, error: "Failed to get ID token.");
        return;
      }

      ApiClient apiClient = ApiClient();
      final response = await apiClient.post('${ApiConstants.baseUrl}/api/oauth/google/mobile', {"idToken": idToken});

final tokenR =  response['token'];

      if (tokenR != null && tokenR.containsKey('access_token')) {
        String token = tokenR['access_token'];
        final user = JwtDecoder.decode(token);

        // print("Auth user gogole $user");

        if (user.isNotEmpty) {
          await SecureStorageService.instance.saveToken(token);
          // print("stored ${user.isNotEmpty}");
          state = state.copyWith(user: user, token: token, isLoading: false);
          // print("state $state");

        }
      } else {
        state = state.copyWith(isLoading: false, error: "Invalid response from server.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
