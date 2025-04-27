// Generic MyDropdownField widget
import 'package:flutter/material.dart';

class MyDropdownField<T> extends StatelessWidget {
  final String? value;
  final List<Map<String, dynamic>> items;
  final String label;
  final Function(String?) onChanged;
  final FormFieldValidator? validator;

  const MyDropdownField(
      {super.key,
      required this.value,
      required this.items,
      required this.label,
      required this.onChanged,
      this.validator});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item['_id'],
                child: Text(item['name']),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        filled: true,
        fillColor: isDarkMode
            ? const Color.fromARGB(255, 42, 42, 42).withOpacity(0.15)
            : Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDarkMode
                  ? const Color.fromARGB(158, 255, 255, 255)
                  : Colors.grey.shade400,
              width: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDarkMode
                  ? const Color.fromARGB(255, 37, 37, 37)
                  : Colors.blue.shade400,
              width: 2),
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      dropdownColor:
          isDarkMode ? const Color.fromARGB(255, 19, 18, 18) : Colors.white,
    );
  }
}
