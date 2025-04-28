import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onClear;
  final Color fg;
  final Color cardBg;
  final Color muted;
  final Color border;
  final Color accent;

  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.fg,
    required this.cardBg,
    required this.muted,
    required this.border,
    required this.accent,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w500),
        cursorColor: fg,
        decoration: InputDecoration(
          filled: true,
          fillColor: cardBg,
          hintText: 'Search societies...',
          hintStyle: TextStyle(color: muted, fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search, color: muted),
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
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: muted),
                  onPressed: onClear,
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}
