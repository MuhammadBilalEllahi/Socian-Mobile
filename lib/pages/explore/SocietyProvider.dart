import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/pages/explore/society.model.dart';
import 'package:socian/shared/services/api_client.dart';

class PaginatedList<T> {
  final List<T> items;
  final int page;
  final int total;
  final int limit;
  final bool isLoading;
  final bool isLoadingMore;

  PaginatedList({
    this.items = const [],
    this.page = 1,
    this.total = 0,
    this.limit = 10,
    this.isLoading = false,
    this.isLoadingMore = false,
  });

  bool get hasMore => items.length < total;

  PaginatedList<T> copyWith({
    List<T>? items,
    int? page,
    int? total,
    int? limit,
    bool? isLoading,
    bool? isLoadingMore,
  }) {
    return PaginatedList<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class SocietiesState {
  final PaginatedList<Society> universitiesSocieties;
  final PaginatedList<Society> universitySocieties;
  final PaginatedList<Society> campusSocieties;
  final List<Society> mergedSocieties;
  final List<Society> filteredSocieties;
  final List<Society> subscribedSocieties;
  final List<Society> publicSocieties;
  final List<Society> otherSocieties;
  final bool isLoadingSearch;
  final String? error;

  SocietiesState({
    PaginatedList<Society>? universitiesSocieties,
    PaginatedList<Society>? universitySocieties,
    PaginatedList<Society>? campusSocieties,
    this.mergedSocieties = const [],
    this.filteredSocieties = const [],
    this.subscribedSocieties = const [],
    this.publicSocieties = const [],
    this.otherSocieties = const [],
    this.isLoadingSearch = false,
    this.error,
  })  : universitiesSocieties =
            universitiesSocieties ?? PaginatedList<Society>(),
        universitySocieties = universitySocieties ?? PaginatedList<Society>(),
        campusSocieties = campusSocieties ?? PaginatedList<Society>();

  SocietiesState copyWith({
    PaginatedList<Society>? universitiesSocieties,
    PaginatedList<Society>? universitySocieties,
    PaginatedList<Society>? campusSocieties,
    List<Society>? mergedSocieties,
    List<Society>? filteredSocieties,
    List<Society>? subscribedSocieties,
    List<Society>? publicSocieties,
    List<Society>? otherSocieties,
    bool? isLoadingSearch,
    String? error,
  }) {
    return SocietiesState(
      universitiesSocieties:
          universitiesSocieties ?? this.universitiesSocieties,
      universitySocieties: universitySocieties ?? this.universitySocieties,
      campusSocieties: campusSocieties ?? this.campusSocieties,
      mergedSocieties: mergedSocieties ?? this.mergedSocieties,
      filteredSocieties: filteredSocieties ?? this.filteredSocieties,
      subscribedSocieties: subscribedSocieties ?? this.subscribedSocieties,
      publicSocieties: publicSocieties ?? this.publicSocieties,
      otherSocieties: otherSocieties ?? this.otherSocieties,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      error: error,
    );
  }
}

class SocietiesNotifier extends StateNotifier<SocietiesState> {
  final ApiClient _apiClient;
  SocietiesNotifier(this._apiClient) : super(SocietiesState()) {
    fetchAllSocieties();
  }

  Future<void> fetchUniversitiesSocieties({bool loadMore = false}) async {
    final current = state.universitiesSocieties;
    final nextPage = loadMore ? current.page + 1 : 1;
    if (loadMore) {
      state = state.copyWith(
        universitiesSocieties: current.copyWith(isLoadingMore: true),
      );
    } else {
      state = state.copyWith(
        universitiesSocieties:
            current.copyWith(isLoading: true, page: 1, items: []),
      );
    }
    try {
      final response = await _apiClient.get(
          '/api/society/paginated/universities/all?page=$nextPage&limit=${current.limit}');
      final data = response['data'] as List;
      final total = response['total'] as int;
      final page = response['page'] as int;
      final limit = response['limit'] as int;
      final societies = data.map((e) => Society.fromMap(e)).toList();
      final newItems = loadMore ? [...current.items, ...societies] : societies;
      state = state.copyWith(
        universitiesSocieties: current.copyWith(
          items: newItems,
          page: page,
          total: total,
          limit: limit,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        universitiesSocieties:
            current.copyWith(isLoading: false, isLoadingMore: false),
      );
    }
  }

  Future<void> fetchUniversitySocieties({bool loadMore = false}) async {
    final current = state.universitySocieties;
    final nextPage = loadMore ? current.page + 1 : 1;
    if (loadMore) {
      state = state.copyWith(
        universitySocieties: current.copyWith(isLoadingMore: true),
      );
    } else {
      state = state.copyWith(
        universitySocieties:
            current.copyWith(isLoading: true, page: 1, items: []),
      );
    }
    try {
      final response = await _apiClient.get(
          '/api/society/paginated/campuses/all?page=$nextPage&limit=${current.limit}');
      final data = response['data'] as List;
      final total = response['total'] as int;
      final page = response['page'] as int;
      final limit = response['limit'] as int;
      final societies = data.map((e) => Society.fromMap(e)).toList();
      final newItems = loadMore ? [...current.items, ...societies] : societies;
      state = state.copyWith(
        universitySocieties: current.copyWith(
          items: newItems,
          page: page,
          total: total,
          limit: limit,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        universitySocieties:
            current.copyWith(isLoading: false, isLoadingMore: false),
      );
    }
  }

  Future<void> fetchCampusSocieties({bool loadMore = false}) async {
    final current = state.campusSocieties;
    final nextPage = loadMore ? current.page + 1 : 1;
    if (loadMore) {
      state = state.copyWith(
        campusSocieties: current.copyWith(isLoadingMore: true),
      );
    } else {
      state = state.copyWith(
        campusSocieties: current.copyWith(isLoading: true, page: 1, items: []),
      );
    }
    try {
      final response = await _apiClient.get(
          '/api/society/paginated/campus/all?page=$nextPage&limit=${current.limit}');
      final data = response['data'] as List;
      final total = response['total'] as int;
      final page = response['page'] as int;
      final limit = response['limit'] as int;
      final societies = data.map((e) => Society.fromMap(e)).toList();
      final newItems = loadMore ? [...current.items, ...societies] : societies;
      state = state.copyWith(
        campusSocieties: current.copyWith(
          items: newItems,
          page: page,
          total: total,
          limit: limit,
          isLoading: false,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        campusSocieties:
            current.copyWith(isLoading: false, isLoadingMore: false),
      );
    }
  }

  Future<void> fetchAllSocieties() async {
    state = state.copyWith(
      universitiesSocieties:
          state.universitiesSocieties.copyWith(isLoading: true),
      universitySocieties: state.universitySocieties.copyWith(isLoading: true),
      campusSocieties: state.campusSocieties.copyWith(isLoading: true),
      isLoadingSearch: true,
      error: null,
    );
    try {
      final responses = await Future.wait([
        _apiClient.get(
            '/api/society/paginated/universities/all?page=1&limit=${state.universitiesSocieties.limit}'),
        _apiClient.get(
            '/api/society/paginated/campuses/all?page=1&limit=${state.universitySocieties.limit}'),
        _apiClient.get(
            '/api/society/paginated/campus/all?page=1&limit=${state.campusSocieties.limit}'),
        _apiClient.get('/api/society/user/subscribedSocieties'),
        _apiClient.get('/api/society/public/societies'),
      ]);
      final universitiesData = responses[0] ?? {};
      final universityData = responses[1] ?? {};
      final campusData = responses[2] ?? {};
      final universitiesSocieties =
          _parseSocietiesList(universitiesData['data'] ?? []);
      final universitySocieties =
          _parseSocietiesList(universityData['data'] ?? []);
      final campusSocieties = _parseSocietiesList(campusData['data'] ?? []);
      final subscribedSocieties = _parseSocietiesList(responses[3] ?? []);
      final publicSocieties = _parseSocietiesList(responses[4] ?? []);
      final List<Society> allSocieties = [
        ...universitiesSocieties,
        ...universitySocieties,
        ...campusSocieties,
      ];
      final Map<String, Society> uniqueSocieties = {};
      for (final society in allSocieties) {
        uniqueSocieties[society.id] = society;
      }
      final mergedSocieties = uniqueSocieties.values.toList();
      final Set<String> subscribedIds =
          subscribedSocieties.map((s) => s.id).toSet();
      final Set<String> publicIds = publicSocieties.map((s) => s.id).toSet();
      final otherSocieties = mergedSocieties.where((s) {
        return !subscribedIds.contains(s.id) && !publicIds.contains(s.id);
      }).toList();
      state = state.copyWith(
        universitiesSocieties: state.universitiesSocieties.copyWith(
          items: universitiesSocieties,
          page: universitiesData['page'] ?? 1,
          total: universitiesData['total'] ?? universitiesSocieties.length,
          limit: universitiesData['limit'] ?? state.universitiesSocieties.limit,
          isLoading: false,
          isLoadingMore: false,
        ),
        universitySocieties: state.universitySocieties.copyWith(
          items: universitySocieties,
          page: universityData['page'] ?? 1,
          total: universityData['total'] ?? universitySocieties.length,
          limit: universityData['limit'] ?? state.universitySocieties.limit,
          isLoading: false,
          isLoadingMore: false,
        ),
        campusSocieties: state.campusSocieties.copyWith(
          items: campusSocieties,
          page: campusData['page'] ?? 1,
          total: campusData['total'] ?? campusSocieties.length,
          limit: campusData['limit'] ?? state.campusSocieties.limit,
          isLoading: false,
          isLoadingMore: false,
        ),
        mergedSocieties: mergedSocieties,
        subscribedSocieties: subscribedSocieties,
        publicSocieties: publicSocieties,
        otherSocieties: otherSocieties,
        filteredSocieties: List<Society>.from(mergedSocieties),
        isLoadingSearch: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        universitiesSocieties:
            state.universitiesSocieties.copyWith(isLoading: false),
        universitySocieties:
            state.universitySocieties.copyWith(isLoading: false),
        campusSocieties: state.campusSocieties.copyWith(isLoading: false),
        isLoadingSearch: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchNextPage(String type) async {
    switch (type) {
      case 'universities':
        if (state.universitiesSocieties.hasMore &&
            !state.universitiesSocieties.isLoadingMore) {
          await fetchUniversitiesSocieties(loadMore: true);
        }
        break;
      case 'university':
        if (state.universitySocieties.hasMore &&
            !state.universitySocieties.isLoadingMore) {
          await fetchUniversitySocieties(loadMore: true);
        }
        break;
      case 'campus':
        if (state.campusSocieties.hasMore &&
            !state.campusSocieties.isLoadingMore) {
          await fetchCampusSocieties(loadMore: true);
        }
        break;
    }
  }

  List<Society> _parseSocietiesList(dynamic list) {
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map((society) => Society.fromMap(society))
          .toList();
    }
    return [];
  }

  void filterSocieties(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      state = state.copyWith(
          filteredSocieties: List<Society>.from(state.mergedSocieties));
    } else {
      state = state.copyWith(
        filteredSocieties: state.mergedSocieties.where((society) {
          final name = (society.name).toLowerCase();
          final description = (society.description ?? '').toLowerCase();
          return name.contains(q) || description.contains(q);
        }).toList(),
      );
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final societiesProvider =
    StateNotifierProvider<SocietiesNotifier, SocietiesState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SocietiesNotifier(apiClient);
});
