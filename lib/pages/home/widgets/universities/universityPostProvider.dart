import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/shared/services/api_client.dart';

class UniversityPostProvider extends ChangeNotifier {
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
  final Duration cacheDuration = const Duration(minutes: 5);

  Future<void> fetchPosts({
    bool refreshIt = false,
    // bool campus = false,
    // bool intraCampus = false,
    // bool universities = false,
  }) async {
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
      // String route = campus
      //     ? ApiConstants.postsCampus
      //     : intraCampus
      //         ? ApiConstants.intraCampusPosts
      //         : universities
      //             ? ApiConstants.universiyPosts
      //             : '';
      // if (route.isEmpty) {
      //   throw 'Invalid route configuration';
      // }
      final response = await apiClient.get(ApiConstants.universiyPosts);

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
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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

// Create a Riverpod provider for UniversityPostProvider
final universitypostProvider =
    ChangeNotifierProvider<UniversityPostProvider>((ref) {
  return UniversityPostProvider();
});
