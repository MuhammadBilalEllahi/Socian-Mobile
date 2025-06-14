import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message,
    {bool isError = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: isDark ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isError
          ? (isDark ? Colors.red[100] : Colors.red[800])
          : (isDark ? Colors.white : Colors.black),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      duration: const Duration(seconds: 3),
    ),
  );
}
