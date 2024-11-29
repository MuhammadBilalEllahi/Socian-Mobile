import 'dart:convert';

import 'package:beyondtheclass/features/auth/domain/auth_usecase.dart';
import 'package:beyondtheclass/features/auth/domain/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


class AuthController extends StateNotifier<AuthState> {
  final AuthUseCases authUseCases;

  AuthController({required this.authUseCases}) : super(const AuthState());

  Future<void> login(String email, String password) async {
    print(
        "2 - File: auth_controller.dart - This is credentials: $email and $password");

    state = state.copyWith(isLoading: true);

    try {
      final response = await authUseCases.login(email, password);

      print("cameback here $response");

      final token = response['token'];
      print("token here $token");

      // String yourToken = "";
      Map<String, dynamic> user = JwtDecoder.decode(token);

      // final user = jsonDecode(token);


// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NzE0MmFlZmEwYWVjMmI0NGJiNDg5OGMiLCJuYW1lIjoiYmlsYWwiLCJlbWFpbCI6ImZhMjEtYmNzLTA1OEBjdWlsYWhvcmUuZWR1LnBrIiwidXNlcm5hbWUiOiJmYTIxLWJjcy0wNThAY3VpbGFob3JlLmVkdS5wayIsInByb2ZpbGUiOnsicmVzcGVjdCI6eyJwb3N0UmVzcGVjdCI6MCwiY29tbWVudFJlc3BlY3QiOjB9LCJwaWN0dXJlIjoiaHR0cHM6Ly9pY29uLWxpYnJhcnkuY29tL2ltYWdlcy9hbm9ueW1vdXMtYXZhdGFyLWljb24vYW5vbnltb3VzLWF2YXRhci1pY29uLTI1LmpwZyIsImJpbyI6IiIsIndlYnNpdGUiOiIiLCJzb2NpYWxMaW5rcyI6W119LCJ1bml2ZXJzaXR5Ijp7ImNhbXB1c0lkIjp7ImVtYWlsUGF0dGVybnMiOnsiY29udmVydGVkUmVnRXgiOnsic3R1ZGVudFBhdHRlcm5zIjpbXSwidGVhY2hlclBhdHRlcm5zIjpbXX0sInN0dWRlbnRQYXR0ZXJucyI6WyJmYTIxLWJjcy0wNDhAY3VpbGFob3JlLmVkdS5wayIsImZhMjItYmNzLTA1NkBjdWlsYWhvcmUuZWR1LnBrIiwiZmEyNC1iY3MtMDA4QGN1aWxhaG9yZS5lZHUucGsiLCJmYTI5LWJjcy0wMDFAY3VpbGFob3JlLmVkdS5wayJdLCJ0ZWFjaGVyUGF0dGVybnMiOltdfSwicmVnaXN0ZXJlZCI6eyJpc1JlZ2lzdGVyZWQiOnRydWV9LCJhY2FkZW1pYyI6eyJGb3JtYXRJZCI6IjY3MWQxOWY1ZjJkMjA1MWIyNDg5ZDRmYSIsIkZvcm1hdFR5cGUiOiJNSURURVJNIn0sIl9pZCI6IjY3MTQyMzU5NzYzMzNlNjE


// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NzE0MmFlZmEwYWVjMmI0NGJiNDg5OGMiLCJuYW1lIjoiYmlsYWwiLCJlbWFpbCI6ImZhMjEtYmNzLTA1OEBjdWlsYWhvcmUuZWR1LnBrIiwidXNlcm5hbWUiOiJmYTIxLWJjcy0wNThAY3VpbGFob3JlLmVkdS5wayIsInByb2ZpbGUiOnsicmVzcGVjdCI6eyJwb3N0UmVzcGVjdCI6MCwiY29tbWVudFJlc3BlY3QiOjB9LCJwaWN0dXJlIjoiaHR0cHM6Ly9pY29uLWxpYnJhcnkuY29tL2ltYWdlcy9hbm9ueW1vdXMtYXZhdGFyLWljb24vYW5vbnltb3VzLWF2YXRhci1pY29uLTI1LmpwZyIsImJpbyI6IiIsIndlYnNpdGUiOiIiLCJzb2NpYWxMaW5rcyI6W119LCJ1bml2ZXJzaXR5Ijp7ImNhbXB1c0lkIjp7ImVtYWlsUGF0dGVybnMiOnsiY29udmVydGVkUmVnRXgiOnsic3R1ZGVudFBhdHRlcm5zIjpbXSwidGVhY2hlclBhdHRlcm5zIjpbXX0sInN0dWRlbnRQYXR0ZXJucyI6WyJmYTIxLWJjcy0wNDhAY3VpbGFob3JlLmVkdS5wayIsImZhMjItYmNzLTA1NkBjdWlsYWhvcmUuZWR1LnBrIiwiZmEyNC1iY3MtMDA4QGN1aWxhaG9yZS5lZHUucGsiLCJmYTI5LWJjcy0wMDFAY3VpbGFob3JlLmVkdS5wayJdLCJ0ZWFjaGVyUGF0dGVybnMiOltdfSwicmVnaXN0ZXJlZCI6eyJpc1JlZ2lzdGVyZWQiOnRydWV9LCJhY2FkZW1pYyI6eyJGb3JtYXRJZCI6IjY3MWQxOWY1ZjJkMjA1MWIyNDg5ZDRmYSIsIkZvcm1hdFR5cGUiOiJNSURURVJNIn0sIl9pZCI6IjY3MTQyMzU5NzYzMzNlNjE
//       print("\n\n\n user here $user");

      state = state.copyWith(user: user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
