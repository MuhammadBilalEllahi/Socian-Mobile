import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/explore/society.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/pages/explore/SocietyProvider.dart';

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

  Color get _bg => Colors.black;
  Color get _fg => Colors.white;
  Color get _cardBg => const Color(0xFF18181B);
  Color get _border => const Color(0xFF27272A);
  Color get _muted => const Color(0xFF71717A);
  Color get _accent => Colors.white;
  Color get _joinedBg => const Color(0xFF27272A);
  Color get _joinedFg => Colors.white;
  Color get _chipBg => const Color(0xFF27272A);
  Color get _chipFg => Colors.white;

  Widget _buildVerticalSocietyCard(Society society, bool isJoined) {
    List<String> fields = [];
    if (society.university != null) fields.add('university');
    if (society.campus != null) fields.add('campus');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (society.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  society.image!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: _border,
                    child: Icon(Icons.broken_image, size: 30, color: _muted),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group, size: 30, color: _muted),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            society.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: _fg,
                              overflow: TextOverflow.ellipsis,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        if (isJoined)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _joinedBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _border, width: 1),
                            ),
                            child: Text(
                              'Joined',
                              style: TextStyle(
                                color: _joinedFg,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (fields.contains('university'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'University: ${society.university ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (fields.contains('campus'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Campus: ${society.campus ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: _muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (society.category != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Category: ${society.category}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (society.membersCount != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Members: ${society.membersCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (society.allows != null && society.allows!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          'Allows: ${society.allows!.map((e) => e[0].toUpperCase() + e.substring(1)).join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      society.description ?? 'No Description',
                      style: TextStyle(
                        fontSize: 13,
                        color: _fg.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                  ),
                  Container(
                    width: double.infinity,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(top: 6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalShimmerList({int count = 6}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => _buildVerticalShimmerCard(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        style: TextStyle(color: _fg, fontSize: 16, fontWeight: FontWeight.w500),
        cursorColor: _fg,
        decoration: InputDecoration(
          filled: true,
          fillColor: _cardBg,
          hintText: 'Search societies...',
          hintStyle: TextStyle(color: _muted, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search, color: _muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _border, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _border, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _accent, width: 1.5),
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: _muted),
                  onPressed: () {
                    searchController.clear();
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildFilterBar(List<Society> allSocieties) {
    final universities = getAllUniversities(allSocieties);
    final campuses = getAllCampuses(allSocieties);
    final allowsOptions = getAllAllows(allSocieties);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // University filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedUniversity,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "University",
                labelStyle: TextStyle(color: _muted),
                filled: true,
                fillColor: _cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text("All", style: TextStyle(color: _fg)),
                ),
                ...universities.map((u) => DropdownMenuItem<String>(
                      value: u,
                      child: Text(u, style: TextStyle(color: _fg)),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedUniversity = value;
                  // Reset campus if university changes
                  selectedCampus = null;
                });
              },
              dropdownColor: _cardBg,
            ),
          ),
          const SizedBox(width: 10),
          // Campus filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCampus,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Campus",
                labelStyle: TextStyle(color: _muted),
                filled: true,
                fillColor: _cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text("All", style: TextStyle(color: _fg)),
                ),
                ...campuses.where((c) {
                  if (selectedUniversity == null) return true;
                  // Only show campuses for selected university
                  return allSocieties.any((s) =>
                      s.campus == c && s.university == selectedUniversity);
                }).map((c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c, style: TextStyle(color: _fg)),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCampus = value;
                });
              },
              dropdownColor: _cardBg,
            ),
          ),
          const SizedBox(width: 10),
          // Allows filter
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedAllows,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Allows",
                labelStyle: TextStyle(color: _muted),
                filled: true,
                fillColor: _cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _border, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text("All", style: TextStyle(color: _fg)),
                ),
                ...allowsOptions.map((a) => DropdownMenuItem<String>(
                      value: a,
                      child: Text(a, style: TextStyle(color: _fg)),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedAllows = value;
                });
              },
              dropdownColor: _cardBg,
            ),
          ),
        ],
      ),
    );
  }

  List<Society> _applyFilters(List<Society> societies) {
    return societies.where((s) {
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
  }

  Widget _buildVerticalSocietiesList(SocietiesState state) {
    if (state.isLoadingSearch) {
      return _buildVerticalShimmerList(count: 6);
    }
    final query = searchController.text.trim().toLowerCase();

    // Apply filters to all lists
    List<Society> filteredSubscribed = _applyFilters(state.subscribedSocieties);
    List<Society> filteredPublic = _applyFilters(state.publicSocieties);
    List<Society> filteredOther = _applyFilters(state.otherSocieties);

    if (query.isNotEmpty) {
      filteredSubscribed = filteredSubscribed.where((society) {
        final name = (society.name).toLowerCase();
        final description = (society.description ?? '').toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
      filteredPublic = filteredPublic.where((society) {
        final name = (society.name).toLowerCase();
        final description = (society.description ?? '').toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
      filteredOther = filteredOther.where((society) {
        final name = (society.name).toLowerCase();
        final description = (society.description ?? '').toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }
    final totalCount = filteredSubscribed.length +
        filteredPublic.length +
        filteredOther.length;
    if (totalCount == 0) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "No societies found.",
          style: TextStyle(fontSize: 16, color: _muted),
        ),
      );
    }
    List<Widget> children = [];
    if (filteredSubscribed.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 12, top: 12, bottom: 4),
        child: Text(
          "Joined Societies",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _fg,
            letterSpacing: -0.5,
          ),
        ),
      ));
      children.addAll(filteredSubscribed
          .map((society) => _buildVerticalSocietyCard(society, true)));
    }
    if (filteredPublic.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 12, top: 16, bottom: 4),
        child: Text(
          "Public Societies",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _fg,
            letterSpacing: -0.5,
          ),
        ),
      ));
      children.addAll(filteredPublic
          .map((society) => _buildVerticalSocietyCard(society, false)));
    }
    if (filteredOther.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 12, top: 16, bottom: 4),
        child: Text(
          "Other Societies",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _fg,
            letterSpacing: -0.5,
          ),
        ),
      ));
      children.addAll(filteredOther
          .map((society) => _buildVerticalSocietyCard(society, false)));
    }
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  Widget _buildSocietyCard(Society society, List<String> fields) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      width: MediaQuery.of(context).size.width * 0.85,
      height: 140,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            if (society.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  society.image!,
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 45,
                    height: 45,
                    color: _border,
                    child: Icon(Icons.broken_image, size: 32, color: _muted),
                  ),
                ),
              )
            else
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.group, size: 32, color: _muted),
              ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and badge row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          society.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: _fg,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (society.category != null)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _chipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            society.category!,
                            style: TextStyle(
                              fontSize: 11,
                              color: _chipFg,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // University & Campus
                  Row(
                    children: [
                      if (fields.contains('university') &&
                          society.university != null)
                        Flexible(
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 13, color: _muted),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  society.university!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _muted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (fields.contains('campus') && society.campus != null)
                        Flexible(
                          child: Row(
                            children: [
                              if (fields.contains('university') &&
                                  society.university != null)
                                const SizedBox(width: 10),
                              Icon(Icons.location_on, size: 13, color: _muted),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  society.campus!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _muted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (fields.contains('campus-self') &&
                          society.campus != null)
                        Flexible(
                          child: Row(
                            children: [
                              Icon(Icons.home, size: 13, color: _muted),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  society.campus!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _muted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  // Members & Allows
                  Row(
                    children: [
                      if (society.membersCount != null)
                        Row(
                          children: [
                            Icon(Icons.people, size: 13, color: _muted),
                            const SizedBox(width: 3),
                            Text(
                              '${society.membersCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _muted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      if (society.allows != null && society.allows!.isNotEmpty)
                        Row(
                          children: [
                            if (society.membersCount != null)
                              const SizedBox(width: 10),
                            Icon(Icons.lock_open, size: 13, color: _muted),
                            const SizedBox(width: 3),
                            Text(
                              society.allows!
                                  .map((e) =>
                                      e[0].toUpperCase() + e.substring(1))
                                  .join(", "),
                              style: TextStyle(
                                fontSize: 12,
                                color: _muted,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                  // const SizedBox(height: 6),
                  // Description
                  // Expanded(
                  //   child: Text(
                  //     society.description?.trim().isNotEmpty == true
                  //         ? society.description!
                  //         : 'No Description',
                  //     style: TextStyle(
                  //       fontSize: 13,
                  //       color: _fg.withOpacity(0.85),
                  //       fontWeight: FontWeight.w400,
                  //       height: 1.3,
                  //     ),
                  //     maxLines: 2,
                  //     overflow: TextOverflow.ellipsis,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      width: 280,
      height: 120,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(right: 12),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                    ),
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      margin: const EdgeInsets.only(top: 6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList({int count = 3}) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: count,
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildHorizontalSocietiesList(
      List<Society> societies, List<String> fields, bool isLoading) {
    if (isLoading) {
      return _buildShimmerList(count: 3);
    }
    // Apply filters
    final filtered = _applyFilters(societies);
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "No societies found.",
          style: TextStyle(fontSize: 16, color: _muted),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: filtered.length,
        itemBuilder: (BuildContext context, int index) {
          final society = filtered[index];
          return _buildSocietyCard(society, fields);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(societiesProvider);
    final auth = ref.read(authProvider);

    // Gather all societies for filter dropdowns
    final allSocieties = [
      ...state.subscribedSocieties,
      ...state.publicSocieties,
      ...state.otherSocieties,
      ...state.universitiesSocieties,
      ...state.universitySocieties,
      ...state.campusSocieties,
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildSearchBar(),
              _buildFilterBar(allSocieties),
              const SizedBox(height: 8),
              isSearchActive
                  ? _buildVerticalSocietiesList(state)
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
                        _buildHorizontalSocietiesList(
                            state.universitiesSocieties,
                            ['university'],
                            state.isLoadingUniversities),
                        Divider(
                          color: _border,
                          thickness: 1,
                          height: 24,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Text(
                            "All Over ${auth.user?['references']['university']['name'].toString().toLowerCase().replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase()) ?? 'your campus'}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _fg,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        _buildHorizontalSocietiesList(state.universitySocieties,
                            ['campus'], state.isLoadingUniversity),
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
                        _buildHorizontalSocietiesList(state.campusSocieties,
                            ['campus-self'], state.isLoadingCampus),
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
    );
  }
}
