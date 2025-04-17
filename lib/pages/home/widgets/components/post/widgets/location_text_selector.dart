import 'package:flutter/material.dart';
import 'searchable_dropdown.dart';

class LocationTextSelector extends StatefulWidget {
  final String? selectedLocation;
  final Function(String?) onLocationSelected;

  const LocationTextSelector({
    super.key,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationTextSelector> createState() => _LocationTextSelectorState();
}

class _LocationTextSelectorState extends State<LocationTextSelector> {
  // Dummy data for locations - replace with actual API data
  final List<Map<String, dynamic>> _locations = [
    {'id': '1', 'name': 'Lahore'},
    {'id': '2', 'name': 'Islamabad'},
    {'id': '3', 'name': 'Karachi'},
    {'id': '4', 'name': 'Peshawar'},
    {'id': '5', 'name': 'Quetta'},
    {'id': '6', 'name': 'Faisalabad'},
    {'id': '7', 'name': 'Multan'},
    {'id': '8', 'name': 'Rawalpindi'},
  ];

  Map<String, dynamic>? _getSelectedLocation() {
    if (widget.selectedLocation == null) return null;
    return _locations.firstWhere(
      (location) => location['name'] == widget.selectedLocation,
      orElse: () => _locations.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Location',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SearchableDropdown<Map<String, dynamic>>(
              label: 'Location',
              hint: 'Search for a location',
              value: _getSelectedLocation(),
              items: _locations,
              getLabel: (location) => location['name'] as String,
              onChanged: (location) {
                if (location != null) {
                  widget.onLocationSelected(location['name'] as String);
                  Navigator.pop(context);
                }
              },
              prefixIcon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }
} 