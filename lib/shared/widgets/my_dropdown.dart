
// Generic MyDropdownField widget
import 'package:flutter/material.dart';

class MyDropdownField<T> extends StatelessWidget {
  final String? value;
  final List<Map<String, dynamic>> items;
  final String label;
  final Function(String?) onChanged;
  final FormFieldValidator? validator;

  const MyDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    this.validator
  });

  @override
  Widget build(BuildContext context) {
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
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.teal.shade800.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade800, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.teal.shade800, // Dropdown menu color
    );
  }
}
