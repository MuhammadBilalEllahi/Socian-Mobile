
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
        fillColor: const Color.fromARGB(255, 42, 42, 42).withValues(alpha: 0.15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(158, 255, 255, 255), width: 0.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 37, 37, 37), width: 2),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color.fromARGB(255, 19, 18, 18), // Dropdown menu color
    );
  }
}
