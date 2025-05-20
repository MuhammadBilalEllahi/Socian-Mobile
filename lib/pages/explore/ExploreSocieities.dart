
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
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  bool isSearchActive = false;

  String? selectedUniversity;
  String? selectedCampus;
  String? selectedAllows;

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
    ref.read(societiesProvider.notifier).filterSocieties(searchController.text);
  }

  void _onSearchFocusChanged() {
    setState(() {
      isSearchActive = searchFocusNode.hasFocus;
    });
  }

  List<Society> _applyFilters(List<Society> societies) {
    final query = searchController.text.trim().toLowerCase();

    var filtered = societies.where((s) {
      final matchesUniversity = selectedUniversity == null || s.university == selectedUniversity;
      final matchesCampus = selectedCampus == null || s.campus == selectedCampus;
      final matchesAllows = selectedAllows == null ||
          (s.allows?.map((e) => e.toLowerCase().trim()).contains(selectedAllows!.toLowerCase()) ?? false);
      return matchesUniversity && matchesCampus && matchesAllows;
    }).toList();

    if (query.isNotEmpty) {
      filtered = filtered.where((s) =>
          s.name.toLowerCase().contains(query) ||
          (s.description?.toLowerCase().contains(query) ?? false)).toList();
    }

    return filtered;
  }

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

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge!.color!;
    final bgColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.fetchAllSocieties();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    custom.SearchBar(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      fg: textColor,
                      cardBg: theme.cardColor,
                      muted: theme.hintColor,
                      border: theme.dividerColor,
                      accent: textColor,
                      onClear: () => setState(() => searchController.clear()),
                    ),
                    const SizedBox(height: 12),
                    FilterBar(
                      allSocieties: allSocieties,
                      selectedUniversity: selectedUniversity,
                      selectedCampus: selectedCampus,
                      selectedAllows: selectedAllows,
                      onUniversityChanged: (val) => setState(() {
                        selectedUniversity = val;
                        selectedCampus = null;
                      }),
                      onCampusChanged: (val) => setState(() => selectedCampus = val),
                      onAllowsChanged: (val) => setState(() => selectedAllows = val),
                      fg: textColor,
                      cardBg: theme.cardColor,
                      muted: theme.hintColor,
                      border: theme.dividerColor,
                      accent: textColor,
                    ),
                    const SizedBox(height: 20),
                    isSearchActive
                        ? VerticalSocietiesList(
                            state: state,
                            fg: textColor,
                            cardBg: theme.cardColor,
                            border: theme.dividerColor,
                            muted: theme.hintColor,
                            joinedBg: theme.highlightColor,
                            joinedFg: textColor,
                            filterFn: _applyFilters,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle("Across Pakistan", textColor),
                              HorizontalSocietiesList(
                                societies: state.universitiesSocieties.items,
                                fields: ['university'],
                                isLoading: state.universitiesSocieties.isLoading,
                                fg: textColor,
                                cardBg: theme.cardColor,
                                border: theme.dividerColor,
                                muted: theme.hintColor,
                                chipBg: Colors.grey.shade200,
                                chipFg: Colors.black,
                                filterFn: _applyFilters,
                                hasMore: state.universitiesSocieties.hasMore,
                                isLoadingMore: state.universitiesSocieties.isLoadingMore,
                                onLoadMore: () => notifier.fetchNextPage('universities'),
                              ),
                              _sectionDivider(theme),
                              _sectionTitle(
                                "All Over ${_capitalize(auth.user?['references']['university']['name']) ?? 'Your Campus'}",
                                textColor,
                              ),
                              HorizontalSocietiesList(
                                societies: state.universitySocieties.items,
                                fields: ['campus'],
                                isLoading: state.universitySocieties.isLoading,
                                fg: textColor,
                                cardBg: theme.cardColor,
                                border: theme.dividerColor,
                                muted: theme.hintColor,
                                chipBg: Colors.grey.shade200,
                                chipFg: Colors.black,
                                filterFn: _applyFilters,
                                hasMore: state.universitySocieties.hasMore,
                                isLoadingMore: state.universitySocieties.isLoadingMore,
                                onLoadMore: () => notifier.fetchNextPage('university'),
                              ),
                              _sectionDivider(theme),
                              _sectionTitle("All Societies in Your Campus", textColor),
                              HorizontalSocietiesList(
                                societies: state.campusSocieties.items,
                                fields: ['campus-self'],
                                isLoading: state.campusSocieties.isLoading,
                                fg: textColor,
                                cardBg: theme.cardColor,
                                border: theme.dividerColor,
                                muted: theme.hintColor,
                                chipBg: Colors.grey.shade200,
                                chipFg: Colors.black,
                                filterFn: _applyFilters,
                                hasMore: state.campusSocieties.hasMore,
                                isLoadingMore: state.campusSocieties.isLoadingMore,
                                onLoadMore: () => notifier.fetchNextPage('campus'),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _sectionDivider(ThemeData theme) {
    return Divider(
      color: theme.dividerColor,
      thickness: 1,
      height: 24,
    );
  }

  String? _capitalize(String? text) {
    if (text == null || text.isEmpty) return null;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

























