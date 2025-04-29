import 'package:flutter/material.dart';
import 'searchable_dropdown.dart';

class SocietySelector extends StatelessWidget {
  final List<Map<String, dynamic>> societies;
  final String? selectedSocietyId;
  final Function(String?) onSocietySelected;

  const SocietySelector({
    super.key,
    required this.societies,
    required this.selectedSocietyId,
    required this.onSocietySelected,
  });

  Map<String, dynamic>? _getSelectedSociety() {
    if (selectedSocietyId == null || societies.isEmpty) return null;
    return societies.firstWhere(
      (society) => society['id'] == selectedSocietyId,
      orElse: () => {} as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchableDropdown<Map<String, dynamic>>(
        label: 'Select Society',
        hint: 'Choose a society',
        value: _getSelectedSociety(),
        items: societies,
        getLabel: (society) => society['name'] as String,
        onChanged: (society) {
          if (society != null) {
            onSocietySelected(society['id'] as String);
          } else {
            onSocietySelected(null);
          }
        },
        prefixIcon: Icons.groups_outlined,
      ),
    );
  }
}
