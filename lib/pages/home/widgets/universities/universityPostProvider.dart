import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';

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

  final bool _hasFetched = false;
  DateTime? _lastFetchedTime;
  final Duration cacheDuration = const Duration(minutes: 5);

  int _page = 1;
  final int _limit = 10;
  bool _hasNextPage = true;

  bool get hasNextPage => _hasNextPage;
  int get page => _page;

  Future<void> fetchPosts({bool refreshIt = false}) async {
    _startProgressAnimation();

    if (!refreshIt &&
        _hasFetched &&
        _lastFetchedTime != null &&
        DateTime.now().difference(_lastFetchedTime!) < cacheDuration) {
      return;
    }

    if (refreshIt) {
      _page = 1;
      _hasNextPage = true;
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }

    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient
          .get('${ApiConstants.universiyPosts}?page=$_page&limit=$_limit');

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

        _hasNextPage = pagination['hasNextPage'] ?? false;
        if (_hasNextPage) _page++;
      } else {
        _errorMessage = 'Invalid API response format';
        _hasError = true;
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      _lastFetchedTime = DateTime.now();
      notifyListeners();
      _completeProgress();
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
