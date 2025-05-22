import 'package:socian/pages/explore/society.model.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final List<Society> allSocieties;
  final String? selectedUniversity;
  final String? selectedCampus;
  final String? selectedAllows;
  final void Function(String?) onUniversityChanged;
  final void Function(String?) onCampusChanged;
  final void Function(String?) onAllowsChanged;
  final Color fg;
  final Color cardBg;
  final Color muted;
  final Color border;
  final Color accent;

  const FilterBar({
    super.key,
    required this.allSocieties,
    required this.selectedUniversity,
    required this.selectedCampus,
    required this.selectedAllows,
    required this.onUniversityChanged,
    required this.onCampusChanged,
    required this.onAllowsChanged,
    required this.fg,
    required this.cardBg,
    required this.muted,
    required this.border,
    required this.accent,
  });

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
  Widget build(BuildContext context) {
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
                labelStyle: TextStyle(color: muted),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: border, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text("All", style: TextStyle(color: fg)),
                ),
                ...universities.map((u) => DropdownMenuItem<String>(
                      value: u,
                      child: Text(u, style: TextStyle(color: fg)),
                    )),
              ],
              onChanged: onUniversityChanged,
              dropdownColor: cardBg,
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
                labelStyle: TextStyle(color: muted),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: border, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text("All", style: TextStyle(color: fg)),
                ),
                ...campuses.where((c) {
                  if (selectedUniversity == null) return true;
                  // Only show campuses for selected university
                  return allSocieties.any((s) =>
                      s.campus == c && s.university == selectedUniversity);
                }).map((c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c, style: TextStyle(color: fg)),
                    )),
              ],
              onChanged: onCampusChanged,
              dropdownColor: cardBg,
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
                labelStyle: TextStyle(color: muted),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: border, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: border, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text("All", style: TextStyle(color: fg)),
                ),
                ...allowsOptions.map((a) => DropdownMenuItem<String>(
                      value: a,
                      child: Text(a, style: TextStyle(color: fg)),
                    )),
              ],
              onChanged: onAllowsChanged,
              dropdownColor: cardBg,
            ),
          ),
        ],
      ),
    );
  }
}
