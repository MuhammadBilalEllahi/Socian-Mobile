import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/core/utils/constants.dart';

class TeachersState {
  final List<dynamic> allTeachers;
  final List<dynamic> filteredTeachers;
  final bool isLoading;
  final String? error;

  TeachersState({
    this.allTeachers = const [],
    this.filteredTeachers = const [],
    this.isLoading = false,
    this.error,
  });

  TeachersState copyWith({
    List<dynamic>? allTeachers,
    List<dynamic>? filteredTeachers,
    bool? isLoading,
    String? error,
  }) {
    return TeachersState(
      allTeachers: allTeachers ?? this.allTeachers,
      filteredTeachers: filteredTeachers ?? this.filteredTeachers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TeachersNotifier extends StateNotifier<TeachersState> {
  final ApiClient apiClient;
  TeachersNotifier(this.apiClient) : super(TeachersState()) {
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await apiClient.get(ApiConstants.campusTeachers);
      if (response is List) {
        state = state.copyWith(
          allTeachers: response,
          filteredTeachers: response,
          isLoading: false,
        );
      } else {
        throw 'Invalid API response format: $response';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load teachers: $e',
      );
    }
  }

  void filterTeachers(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      state = state.copyWith(filteredTeachers: state.allTeachers);
    } else {
      state = state.copyWith(
        filteredTeachers: state.allTeachers.where((teacher) {
          final name = (teacher['name'] ?? '').toString().toLowerCase();
          final department =
              (teacher['department']?['name'] ?? '').toString().toLowerCase();
          return name.contains(q) || department.contains(q);
        }).toList(),
      );
    }
  }
}

final teachersProvider =
    StateNotifierProvider<TeachersNotifier, TeachersState>((ref) {
  return TeachersNotifier(ApiClient());
});
