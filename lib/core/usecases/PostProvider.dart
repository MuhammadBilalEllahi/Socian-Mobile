// import 'package:flutter/material.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class PostProvider extends ChangeNotifier {
//   List<dynamic> _posts = [];
//   bool _isLoading = false;
//   bool _hasError = false;
//   String? _errorMessage;
//
//   List<dynamic> get posts => _posts;
//   bool get isLoading => _isLoading;
//   bool get hasError => _hasError;
//   String? get errorMessage => _errorMessage;
//
//   Future<void> fetchPosts() async {
//     _isLoading = true;
//     _hasError = false;
//     _errorMessage = null;
//     notifyListeners();
//
//     final ApiClient apiClient = ApiClient();
//     try {
//       final response = await apiClient.get(ApiConstants.postsCampus);
//
//       if (response is List) {
//         _posts = response;
//       } else {
//         throw 'Invalid API response format: $response';
//       }
//     } catch (e) {
//       _hasError = true;
//       _errorMessage = 'Failed to load posts: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void clearPosts() {
//     _posts = [];
//     notifyListeners();
//   }
// }
//
// // Create a Riverpod provider for PostProvider
// final postProvider = ChangeNotifierProvider<PostProvider>((ref) {
//   return PostProvider();
// });





import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/core/utils/constants.dart';

class PostProvider extends ChangeNotifier {
  List<dynamic> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    final ApiClient apiClient = ApiClient();
    try {
      final response = await apiClient.get(ApiConstants.postsCampus);

      if (response is List) {
        _posts = response;
      } else {
        throw 'Invalid API response format: $response';
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load posts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPosts() {
    _posts = [];
    notifyListeners();
  }
}

// Create a Riverpod provider for PostProvider
final postProvider = ChangeNotifierProvider<PostProvider>((ref) {
  return PostProvider();
});