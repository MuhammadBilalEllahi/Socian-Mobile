import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/core/utils/constants.dart';

class PostProvider extends ChangeNotifier {
  List<dynamic> _posts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasError = false;
  String? _errorMessage;

  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  final ApiClient apiClient = ApiClient();

  double loadingProgress = 0.0;
  Timer? _progressTimer;

  bool _hasFetched = false;
  DateTime? _lastFetchedTime;
  final Duration cacheDuration = Duration(minutes: 5);

  Future<void> fetchPosts({bool refreshIt = false}) async {
    _startProgressAnimation();

    if (!refreshIt &&
        _hasFetched &&
        _lastFetchedTime != null &&
        DateTime.now().difference(_lastFetchedTime!) < cacheDuration) {
      return;
    }

    if (refreshIt) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }

    _hasFetched = true;
    _lastFetchedTime = DateTime.now();
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

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
      _completeProgress();
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void _startProgressAnimation() {
    loadingProgress = 0.0;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (loadingProgress < 0.9) {
        loadingProgress += 0.02; // increment smoothly
        notifyListeners();
      } else {
        // stop incrementing near 90% to wait for API to finish
        timer.cancel();
      }
    });
  }

  void _completeProgress() {
    _progressTimer?.cancel();
    loadingProgress = 1.0;
    notifyListeners();
  }

  // Don't forget to dispose timer on ChangeNotifier dispose!
  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
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
