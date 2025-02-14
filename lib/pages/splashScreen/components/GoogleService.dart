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
  late final GoogleSignIn _googleSignIn;
  final String googleClientId;

  GoogleSignInService()
      : googleClientId = dotenv.env['GOOGLE_CLIENT_ID'] ?? "",
        super(AuthState.initial()) {
    _googleSignIn = GoogleSignIn(
      clientId: googleClientId,
      scopes: ['email', 'profile'],
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('Google ID: $googleClientId');
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
      final response = await apiClient.post(
        '${ApiConstants.baseUrl}/api/oauth/google/mobile',
        {"idToken": idToken},
      );

      final tokenR = response['token'];

      if (tokenR != null && tokenR.containsKey('access_token')) {
        String token = tokenR['access_token'];
        final user = JwtDecoder.decode(token);

        if (user.isNotEmpty) {
          await SecureStorageService.instance.saveToken(token);
          state = state.copyWith(user: user, token: token, isLoading: false);
           Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        state = state.copyWith(isLoading: false, error: "Invalid response from server.");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
