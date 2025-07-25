import 'package:socian/features/auth/controllers/auth_controller.dart';
import 'package:socian/features/auth/data/auth_data_source.dart';
import 'package:socian/features/auth/data/auth_data_source_impl.dart';
import 'package:socian/features/auth/data/auth_repo.dart';
import 'package:socian/features/auth/data/auth_repo_impl.dart';
import 'package:socian/features/auth/domain/auth_state.dart';
import 'package:socian/features/auth/domain/auth_usecase.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  // debugPrint("T-1 $ref");
  return AuthDataSourceImpl(client: ref.read(apiClientProvider));
});

final authRepoProvider = Provider<AuthRepo>((ref) {
  // debugPrint("T-2 $ref");
  return AuthRepoImpl(ref.read(apiClientProvider));
});

final authUseCasesProvider = Provider<AuthUseCases>((ref) {
  // debugPrint("T-3 $ref");
  return AuthUseCases(ref.read(authDataSourceProvider));
});

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  // debugPrint("T-4 $ref");
  return AuthController(authUseCases: ref.read(authUseCasesProvider));
});


