import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyDropdownField<T> extends StatefulWidget {
  final String? value;
  final List<Map<String, dynamic>> items;
  final String label;
  final Function(String?) onChanged;
  final FormFieldValidator<String>? validator;
  final bool isLoading; // New: loading flag
    final bool disableField; // New: loading flag


  const MyDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    this.validator,
    this.isLoading = false, // default false
        this.disableField = false, // default false

  });

  @override
  State<MyDropdownField<T>> createState() => _MyDropdownFieldState<T>();
}

class _MyDropdownFieldState<T> extends State<MyDropdownField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _filteredItems = [];
  String? _selectedValue;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _searchController = TextEditingController();
    _filteredItems = widget.items;

    final selectedItem = widget.items.firstWhere(
      (item) => item['_id'] == _selectedValue,
      orElse: () => {'name': ''},
    );
    _searchController.text = selectedItem['name'] ?? '';

    _searchController.addListener(_onSearchChanged);
  }

  @override
void didUpdateWidget(covariant MyDropdownField<T> oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (oldWidget.items != widget.items) {
    setState(() {
      _filteredItems = widget.items;

      final stillExists = widget.items.any((item) => item['_id'] == _selectedValue);
      if (!stillExists) {
        _selectedValue = null;
        _searchController.text = '';
      } else {
        final selectedItem = widget.items.firstWhere((item) => item['_id'] == _selectedValue);
        _searchController.text = selectedItem['name'] ?? '';
      }
    });

    // If dropdown is open, refresh overlay to reflect new data
    if (_isOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          
      _removeOverlay();
    _showOverlay();  // deferred after build completes
  });
    }
  }
}

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => item['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
      _unfocusTextField();
    } else {
      _showOverlay();
      _focusTextField();
    }
  }

  void _focusTextField() {
    setState(() {
      _hasFocus = true;
    });
  }

  void _unfocusTextField() {
    setState(() {
      _hasFocus = false;
    });
  }

  void _showOverlay() {
    final overlay = Overlay.of(context)!;
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxHeight = screenHeight * 0.3;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Positioned(
          width: size.width,
          left: offset.dx,
          top: offset.dy + size.height + 5,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 5),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.isLoading
                    ? ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Shimmer.fromColors(
                              baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                              highlightColor: isDarkMode ? Colors.grey[500]! : Colors.grey[100]!,
                              child: Container(
                                width: double.infinity,
                                height: 16,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      )
                    : (_filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: Text("No items found")),
                          )
                        : Scrollbar(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = item['_id'] == _selectedValue;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedValue = item['_id'];
                                      widget.onChanged(_selectedValue);
                                      _searchController.text = item['name'];
                                      _filteredItems = widget.items;
                                    });
                                    _removeOverlay();
                                    _unfocusTextField();
                                  },
                                  child: Container(
                                    color: isSelected
                                        ? (isDarkMode ? Colors.grey[800] : Colors.grey[300])
                                        : null,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    child: Text(item['name']),
                                  ),
                                );
                              },
                            ),
                          )),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.disableField ? null: _toggleDropdown,
        child: AbsorbPointer(
          absorbing: !_isOpen,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: widget.label,
              filled: true,
              fillColor: isDarkMode
                  ? const Color.fromARGB(255, 42, 42, 42).withOpacity(0.15)
                  : Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? const Color.fromARGB(158, 255, 255, 255)
                      : Colors.grey.shade400,
                  width: 0.6,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode
                      ? const Color.fromARGB(255, 37, 37, 37)
                      : Colors.blue.shade400,
                  width: 2,
                ),
              ),
              suffixIcon: Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: isDarkMode ? Colors.white : Colors.black54,
              ),
            ),
            readOnly: !_isOpen,
            onTap: _toggleDropdown,
          ),
        ),
      ),
    );
  }
}




// // Generic MyDropdownField widget
// import 'package:flutter/material.dart';

// class MyDropdownField<T> extends StatelessWidget {
//   final String? value;
//   final List<Map<String, dynamic>> items;
//   final String label;
//   final Function(String?) onChanged;
//   final FormFieldValidator? validator;

//   const MyDropdownField(
//       {super.key,
//       required this.value,
//       required this.items,
//       required this.label,
//       required this.onChanged,
//       this.validator});

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return DropdownButtonFormField<String>(
//       value: value,
//       items: items
//           .map((item) => DropdownMenuItem<String>(
//                 value: item['_id'],
//                 child: Text(item['name']),
//               ))
//           .toList(),
//       onChanged: onChanged,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(
//           color: isDarkMode ? Colors.white : Colors.black87,
//         ),
//         filled: true,
//         fillColor: isDarkMode
//             ? const Color.fromARGB(255, 42, 42, 42).withOpacity(0.15)
//             : Colors.grey.shade100,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//               color: isDarkMode
//                   ? const Color.fromARGB(158, 255, 255, 255)
//                   : Colors.grey.shade400,
//               width: 0.6),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//               color: isDarkMode
//                   ? const Color.fromARGB(255, 37, 37, 37)
//                   : Colors.blue.shade400,
//               width: 2),
//         ),
//       ),
//       style: TextStyle(
//         color: isDarkMode ? Colors.white : Colors.black87,
//       ),
//       dropdownColor:
//           isDarkMode ? const Color.fromARGB(255, 19, 18, 18) : Colors.white,
//     );
//   }
// }
