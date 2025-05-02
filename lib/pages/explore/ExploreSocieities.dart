import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/explore/society.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/pages/explore/SocietyProvider.dart';
import 'components/search/search_bar.dart' as custom;
import 'components/search/filter_bar.dart';
import 'components/horizontal_societies_list.dart';
import 'components/search/vertical_societies_list.dart';

class ExploreSocieties extends ConsumerStatefulWidget {
  const ExploreSocieties({super.key});

  @override
  ConsumerState<ExploreSocieties> createState() => _ExploreSocietiesState();
}

class _ExploreSocietiesState extends ConsumerState<ExploreSocieties> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool isSearchActive = false;

  // Filter state
  String? selectedUniversity;
  String? selectedCampus;
  String? selectedAllows; // "All", "Student", "Teacher", "Alumni"

  List<String> getAllUniversities(List<Society> societies) {
    final set = <String>{};
    for (final s in societies) {
      if (s.university != null && s.university!.trim().isNotEmpty) {
        set.add(s.university!);
      }
    }
    return set.toList()..sort();
  }

  List<String> getAllCampuses(List<Society> societies) {
    final set = <String>{};
    for (final s in societies) {
      if (s.campus != null && s.campus!.trim().isNotEmpty) {
        set.add(s.campus!);
      }
    }
    return set.toList()..sort();
  }

  List<String> getAllAllows(List<Society> societies) {
    final set = <String>{};
    for (final s in societies) {
      if (s.allows != null) {
        for (final allow in s.allows!) {
          set.add(allow.trim().toLowerCase());
        }
      }
    }
    // Normalize to capitalized for display
    final display = set.map((e) {
      if (e == "student") return "Student";
      if (e == "teacher") return "Teacher";
      if (e == "alumni") return "Alumni";
      return e[0].toUpperCase() + e.substring(1);
    }).toSet();
    return display.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final notifier = ref.read(societiesProvider.notifier);
    notifier.filterSocieties(searchController.text);
  }

  void _onSearchFocusChanged() {
    setState(() {
      isSearchActive = searchFocusNode.hasFocus;
    });
  }

  // Light theme colors
  Color get _bg => Theme.of(context).brightness == Brightness.light
      ? Colors.white
      : Colors.black;
  Color get _fg => Theme.of(context).brightness == Brightness.light
      ? Colors.black
      : Colors.white;
  Color get _cardBg => Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFF8F8F8)
      : const Color(0xFF18181B);
  Color get _border => Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFE5E5E5)
      : const Color(0xFF27272A);
  Color get _muted => Theme.of(context).brightness == Brightness.light
      ? const Color(0xFF71717A)
      : const Color(0xFFA1A1AA);
  Color get _accent => Theme.of(context).brightness == Brightness.light
      ? Colors.black
      : Colors.white;
  Color get _joinedBg => Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFF1F1F1)
      : const Color(0xFF27272A);
  Color get _joinedFg => Theme.of(context).brightness == Brightness.light
      ? Colors.black
      : Colors.white;
  Color get _chipBg => Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFF1F1F1)
      : const Color(0xFF27272A);
  Color get _chipFg => Theme.of(context).brightness == Brightness.light
      ? Colors.black
      : Colors.white;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(societiesProvider);
    final notifier = ref.read(societiesProvider.notifier);
    final auth = ref.read(authProvider);
    final allSocieties = [
      ...state.subscribedSocieties,
      ...state.publicSocieties,
      ...state.otherSocieties,
      ...state.universitiesSocieties.items,
      ...state.universitySocieties.items,
      ...state.campusSocieties.items,
    ];

    // Filtering logic for search and dropdowns
    List<Society> filterFn(List<Society> societies) {
      final query = searchController.text.trim().toLowerCase();
      var filtered = societies.where((s) {
        final matchesUniversity =
            selectedUniversity == null || s.university == selectedUniversity;
        final matchesCampus =
            selectedCampus == null || s.campus == selectedCampus;
        final matchesAllows = selectedAllows == null ||
            (s.allows != null &&
                s.allows!
                    .map((e) => e.trim().toLowerCase())
                    .contains(selectedAllows!.toLowerCase()));
        return matchesUniversity && matchesCampus && matchesAllows;
      }).toList();
      if (query.isNotEmpty) {
        filtered = filtered.where((society) {
          final name = (society.name).toLowerCase();
          final description = (society.description ?? '').toLowerCase();
          return name.contains(query) || description.contains(query);
        }).toList();
      }
      return filtered;
    }

    return Scaffold(
      // appBar: AppBar(),
      backgroundColor: _bg,
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.fetchAllSocieties();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 12),
                custom.SearchBar(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  fg: _fg,
                  cardBg: _cardBg,
                  muted: _muted,
                  border: _border,
                  accent: _accent,
                  onClear: () => setState(() => searchController.clear()),
                ),
                FilterBar(
                  allSocieties: allSocieties,
                  selectedUniversity: selectedUniversity,
                  selectedCampus: selectedCampus,
                  selectedAllows: selectedAllows,
                  onUniversityChanged: (value) => setState(() {
                    selectedUniversity = value;
                    selectedCampus = null;
                  }),
                  onCampusChanged: (value) =>
                      setState(() => selectedCampus = value),
                  onAllowsChanged: (value) =>
                      setState(() => selectedAllows = value),
                  fg: _fg,
                  cardBg: _cardBg,
                  muted: _muted,
                  border: _border,
                  accent: _accent,
                ),
                const SizedBox(height: 8),
                isSearchActive
                    ? VerticalSocietiesList(
                        state: state,
                        fg: _fg,
                        cardBg: _cardBg,
                        border: _border,
                        muted: _muted,
                        joinedBg: _joinedBg,
                        joinedFg: _joinedFg,
                        filterFn: filterFn,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Text(
                              "Accross pakistan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _fg,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          HorizontalSocietiesList(
                            societies: state.universitiesSocieties.items,
                            fields: ['university'],
                            isLoading: state.universitiesSocieties.isLoading,
                            fg: _fg,
                            cardBg: _cardBg,
                            border: _border,
                            muted: _muted,
                            chipBg: _chipBg,
                            chipFg: _chipFg,
                            filterFn: filterFn,
                            hasMore: state.universitiesSocieties.hasMore,
                            isLoadingMore:
                                state.universitiesSocieties.isLoadingMore,
                            onLoadMore: () => ref
                                .read(societiesProvider.notifier)
                                .fetchNextPage('universities'),
                          ),
                          Divider(
                            color: _border,
                            thickness: 1,
                            height: 24,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Text(
                              "All Over " +
                                  (auth.user?['references']['university']
                                              ['name']
                                          ?.toString()
                                          .toLowerCase()
                                          .replaceFirstMapped(RegExp(r'^[a-z]'),
                                              (m) => m[0]!.toUpperCase()) ??
                                      'your campus'),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _fg,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          HorizontalSocietiesList(
                            societies: state.universitySocieties.items,
                            fields: ['campus'],
                            isLoading: state.universitySocieties.isLoading,
                            fg: _fg,
                            cardBg: _cardBg,
                            border: _border,
                            muted: _muted,
                            chipBg: _chipBg,
                            chipFg: _chipFg,
                            filterFn: filterFn,
                            hasMore: state.universitySocieties.hasMore,
                            isLoadingMore:
                                state.universitySocieties.isLoadingMore,
                            onLoadMore: () => ref
                                .read(societiesProvider.notifier)
                                .fetchNextPage('university'),
                          ),
                          Divider(
                            color: _border,
                            thickness: 1,
                            height: 24,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Text(
                              "All Societies in Your Campus",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _fg,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          HorizontalSocietiesList(
                            societies: state.campusSocieties.items,
                            fields: ['campus-self'],
                            isLoading: state.campusSocieties.isLoading,
                            fg: _fg,
                            cardBg: _cardBg,
                            border: _border,
                            muted: _muted,
                            chipBg: _chipBg,
                            chipFg: _chipFg,
                            filterFn: filterFn,
                            hasMore: state.campusSocieties.hasMore,
                            isLoadingMore: state.campusSocieties.isLoadingMore,
                            onLoadMore: () => ref
                                .read(societiesProvider.notifier)
                                .fetchNextPage('campus'),
                          ),
                          Divider(
                            color: _border,
                            thickness: 1,
                            height: 24,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
