import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';

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
  final Duration cacheDuration = const Duration(minutes: 5);

  int _page = 1;
  final int _limit = 10;
  bool _hasNextPage = true;

  bool get hasNextPage => _hasNextPage;
  int get page => _page;

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

      _page = 1;
      _hasNextPage = true;
    } else {
      _isLoading = true;
    }

    _hasFetched = true;
    _lastFetchedTime = DateTime.now();
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    debugPrint("[PostProvider] Fetching posts: page=$_page, limit=$_limit");
    try {
      final response = await apiClient
          .get('${ApiConstants.postsCampus}?page=$_page&limit=$_limit');

      if (response is Map<String, dynamic> &&
          response.containsKey('data') &&
          response.containsKey('pagination')) {
        final newPosts = response['data'] as List<dynamic>;
        final pagination = response['pagination'];

        if (_page == 1) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }

        _hasNextPage = pagination['hasNextPage'];
        _page++;
      } else {
        _errorMessage = 'Invalid API response format';
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

// Create a Riverpod provider for PostProvider
final postProvider = ChangeNotifierProvider<PostProvider>((ref) {
  return PostProvider();
});
