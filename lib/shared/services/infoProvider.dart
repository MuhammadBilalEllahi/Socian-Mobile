// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Provider for fetching user data by userId
// final userInfoProvider = FutureProvider.family.autoDispose<Map<String, dynamic>?, String>(
//   (ref, userId) async {
//     if (userId.isEmpty) {
//       debugPrint('Empty userId provided');
//       return null;
//     }

//     // Check if userId matches current user from authProvider
//     // final auth = ref.read(authProvider);
//     final auth = ref.watch(authProvider);
//     if (auth.user != null && auth.user?['_id'] == userId) {
//       final userData = auth.user!;
//       debugPrint('User data from authProvider for $userId: $userData');
//       return userData;
//     }

//     // Fetch from API for other users
//     final apiClient = ApiClient();
//     try {
//       final response = await apiClient.get(
//         '/api/user/profile',
//         queryParameters: {'userid': userId},
//       );
//       debugPrint('User data from API for $userId: $response');
//       return response as Map<String, dynamic>?;
//     } catch (e) {
//       debugPrint('Error fetching user data for $userId: $e');
//       return null; // Return null on error (e.g., 404, 403)
//     }
//   },
// );

// class UserInfoProvider {
//   static Future<Map<String, dynamic>?> getUserData(WidgetRef ref, String userId) {
//     return ref.watch(userInfoProvider(userId).future);
//   }
// }










import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a FutureProvider family for user data, parameterized by userId
final userInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, userId) async {
    if (userId.isEmpty) {
      return null;
    }

    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(
        '/api/user/profile',
        queryParameters: {'id': userId},
      );
      debugPrint('User data response for $userId: $response');
      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error fetching user data for $userId: $e');
      return null;
    }
  },
);

class UserInfoProvider {
  static Future<Map<String, dynamic>?> getUserData(WidgetRef ref, String userId) {
    // Watch the userInfoProvider for the given userId
    return ref.watch(userInfoProvider(userId).future);
  }
}