import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/pages/explore/society.model.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';

class SocietiesState {
  final List<Society> universitiesSocieties;
  final List<Society> universitySocieties;
  final List<Society> campusSocieties;
  final List<Society> mergedSocieties;
  final List<Society> filteredSocieties;
  final List<Society> subscribedSocieties;
  final List<Society> publicSocieties;
  final List<Society> otherSocieties;
  final bool isLoadingUniversities;
  final bool isLoadingUniversity;
  final bool isLoadingCampus;
  final bool isLoadingSearch;
  final String? error;

  SocietiesState({
    this.universitiesSocieties = const [],
    this.universitySocieties = const [],
    this.campusSocieties = const [],
    this.mergedSocieties = const [],
    this.filteredSocieties = const [],
    this.subscribedSocieties = const [],
    this.publicSocieties = const [],
    this.otherSocieties = const [],
    this.isLoadingUniversities = true,
    this.isLoadingUniversity = true,
    this.isLoadingCampus = true,
    this.isLoadingSearch = false,
    this.error,
  });

  SocietiesState copyWith({
    List<Society>? universitiesSocieties,
    List<Society>? universitySocieties,
    List<Society>? campusSocieties,
    List<Society>? mergedSocieties,
    List<Society>? filteredSocieties,
    List<Society>? subscribedSocieties,
    List<Society>? publicSocieties,
    List<Society>? otherSocieties,
    bool? isLoadingUniversities,
    bool? isLoadingUniversity,
    bool? isLoadingCampus,
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
      isLoadingUniversities:
          isLoadingUniversities ?? this.isLoadingUniversities,
      isLoadingUniversity: isLoadingUniversity ?? this.isLoadingUniversity,
      isLoadingCampus: isLoadingCampus ?? this.isLoadingCampus,
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

  Future<void> fetchAllSocieties() async {
    state = state.copyWith(
      isLoadingUniversities: true,
      isLoadingUniversity: true,
      isLoadingCampus: true,
      isLoadingSearch: true,
      error: null,
    );
    try {
      final responses = await Future.wait([
        _apiClient.get('/api/society/universities/all'),
        _apiClient.get('/api/society/campuses/all'),
        _apiClient.get('/api/society/campus/all'),
        _apiClient.get('/api/society/user/subscribedSocieties'),
        _apiClient.get('/api/society/public/societies'),
      ]);
      final universitiesResponse = responses[0];
      final universityResponse = responses[1];
      final campusResponse = responses[2];
      final subscribedResponse = responses[3];
      final publicResponse = responses[4];
      final universitiesSocieties =
          _parseSocietiesList(universitiesResponse ?? []);
      final universitySocieties = _parseSocietiesList(universityResponse ?? []);
      final campusSocieties = _parseSocietiesList(campusResponse ?? []);
      final subscribedSocieties = _parseSocietiesList(subscribedResponse ?? []);
      final publicSocieties = _parseSocietiesList(publicResponse ?? []);
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
        universitiesSocieties: universitiesSocieties,
        universitySocieties: universitySocieties,
        campusSocieties: campusSocieties,
        mergedSocieties: mergedSocieties,
        subscribedSocieties: subscribedSocieties,
        publicSocieties: publicSocieties,
        otherSocieties: otherSocieties,
        filteredSocieties: List<Society>.from(mergedSocieties),
        isLoadingUniversities: false,
        isLoadingUniversity: false,
        isLoadingCampus: false,
        isLoadingSearch: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingUniversities: false,
        isLoadingUniversity: false,
        isLoadingCampus: false,
        isLoadingSearch: false,
        error: e.toString(),
      );
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
