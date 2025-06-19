import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/explore/SocietyProvider.dart';
import 'package:socian/pages/explore/society.model.dart';

import 'components/horizontal_societies_list.dart';
import 'components/search/filter_bar.dart';
import 'components/search/search_bar.dart' as custom;
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
      final matchesUniversity =
          selectedUniversity == null || s.university == selectedUniversity;
      final matchesCampus =
          selectedCampus == null || s.campus == selectedCampus;
      final matchesAllows = selectedAllows == null ||
          (s.allows
                  ?.map((e) => e.toLowerCase().trim())
                  .contains(selectedAllows!.toLowerCase()) ??
              false);
      return matchesUniversity && matchesCampus && matchesAllows;
    }).toList();

    if (query.isNotEmpty) {
      filtered = filtered
          .where((s) =>
              s.name.toLowerCase().contains(query) ||
              (s.description?.toLowerCase().contains(query) ?? false))
          .toList();
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

    // --- shadcn-inspired color palette ---
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Black/white and gray palette
    final Color bgColor = isDark ? const Color(0xFF18181B) : Colors.white;
    final Color cardColor = isDark ? const Color(0xFF232326) : Colors.white;
    final Color borderColor =
        isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final Color textColor = isDark ? Colors.white : const Color(0xFF18181B);
    final Color mutedColor =
        isDark ? const Color(0xFF71717A) : const Color(0xFF71717A);
    final Color accentColor = isDark ? Colors.white : Colors.black;
    final Color chipBg =
        isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final Color chipFg = isDark ? Colors.white : Colors.black;
    final Color joinedBg =
        isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final Color joinedFg = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: accentColor,
          backgroundColor: cardColor,
          onRefresh: () async {
            await notifier.fetchAllSocieties();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar with search and filter
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border(
                            bottom: BorderSide(color: borderColor, width: 1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: custom.SearchBar(
                                    controller: searchController,
                                    focusNode: searchFocusNode,
                                    fg: textColor,
                                    cardBg: cardColor,
                                    muted: mutedColor,
                                    border: borderColor,
                                    accent: accentColor,
                                    onClear: () => setState(
                                        () => searchController.clear()),
                                  ),
                                ),
                                if (isSearchActive)
                                  IconButton(
                                    icon: Icon(Icons.close, color: mutedColor),
                                    tooltip: 'Close search',
                                    onPressed: () {
                                      searchFocusNode.unfocus();
                                      setState(() => searchController.clear());
                                    },
                                  ),
                              ],
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
                              onCampusChanged: (val) =>
                                  setState(() => selectedCampus = val),
                              onAllowsChanged: (val) =>
                                  setState(() => selectedAllows = val),
                              fg: textColor,
                              cardBg: cardColor,
                              muted: mutedColor,
                              border: borderColor,
                              accent: accentColor,
                            ),
                          ],
                        ),
                      ),
                      // Main content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
                        child: isSearchActive
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                child: VerticalSocietiesList(
                                  state: state,
                                  fg: textColor,
                                  cardBg: cardColor,
                                  border: borderColor,
                                  muted: mutedColor,
                                  joinedBg: joinedBg,
                                  joinedFg: joinedFg,
                                  filterFn: _applyFilters,
                                  onCardTap: () => searchFocusNode.unfocus(),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle("Across Pakistan", textColor,
                                      borderColor),
                                  HorizontalSocietiesList(
                                    societies:
                                        state.universitiesSocieties.items,
                                    fields: const ['university'],
                                    isLoading:
                                        state.universitiesSocieties.isLoading,
                                    fg: textColor,
                                    cardBg: cardColor,
                                    border: borderColor,
                                    muted: mutedColor,
                                    chipBg: chipBg,
                                    chipFg: chipFg,
                                    filterFn: _applyFilters,
                                    hasMore:
                                        state.universitiesSocieties.hasMore,
                                    isLoadingMore: state
                                        .universitiesSocieties.isLoadingMore,
                                    onLoadMore: () =>
                                        notifier.fetchNextPage('universities'),
                                  ),
                                  _sectionDivider(borderColor),
                                  _sectionTitle(
                                    "All Over ${_capitalize(auth.user?['references']['university']['name']) ?? 'Your Campus'}",
                                    textColor,
                                    borderColor,
                                  ),
                                  HorizontalSocietiesList(
                                    societies: state.universitySocieties.items,
                                    fields: const ['campus'],
                                    isLoading:
                                        state.universitySocieties.isLoading,
                                    fg: textColor,
                                    cardBg: cardColor,
                                    border: borderColor,
                                    muted: mutedColor,
                                    chipBg: chipBg,
                                    chipFg: chipFg,
                                    filterFn: _applyFilters,
                                    hasMore: state.universitySocieties.hasMore,
                                    isLoadingMore:
                                        state.universitySocieties.isLoadingMore,
                                    onLoadMore: () =>
                                        notifier.fetchNextPage('university'),
                                  ),
                                  _sectionDivider(borderColor),
                                  _sectionTitle("All Societies in Your Campus",
                                      textColor, borderColor),
                                  HorizontalSocietiesList(
                                    societies: state.campusSocieties.items,
                                    fields: const ['campus-self'],
                                    isLoading: state.campusSocieties.isLoading,
                                    fg: textColor,
                                    cardBg: cardColor,
                                    border: borderColor,
                                    muted: mutedColor,
                                    chipBg: chipBg,
                                    chipFg: chipFg,
                                    filterFn: _applyFilters,
                                    hasMore: state.campusSocieties.hasMore,
                                    isLoadingMore:
                                        state.campusSocieties.isLoadingMore,
                                    onLoadMore: () =>
                                        notifier.fetchNextPage('campus'),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 24, left: 20, right: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider(Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: borderColor,
        thickness: 1,
        height: 32,
      ),
    );
  }

  String? _capitalize(String? text) {
    if (text == null || text.isEmpty) return null;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
