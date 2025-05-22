// lib/core/usecases/login_user.dart

import 'package:socian/features/auth/data/auth_repo.dart';

class LoginUser {
  final AuthRepo repository;

  LoginUser({required this.repository});

  Future<Map<String, dynamic>> call(String email, String password) {
    return repository.login(email, password);
  }
}
