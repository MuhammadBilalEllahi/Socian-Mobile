import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Displays a customizable GetX Snackbar.
/// @param {String} title - Title of the Snackbar.
/// @param {String} message - Message to display.
/// @param {bool} isError - If true, shows an error Snackbar.
void showCustomSnackbar({
  required String title,
  required String message,
  bool isError = false,
}) {
  Get.snackbar(
    title, 
    message,
    snackPosition: SnackPosition.BOTTOM, // Position of Snackbar
    backgroundColor: isError ? Colors.red : Colors.black87, // Different colors for error/success
    colorText: Colors.white,
    duration: const Duration(seconds: 3), // Auto-dismiss after 3 seconds
    borderRadius: 10,
    margin: const EdgeInsets.all(12),
    icon: Icon(
      isError ? Icons.error_outline : Icons.check_circle,
      color: Colors.white,
    ),
    shouldIconPulse: true,
    animationDuration: const Duration(milliseconds: 300),
    overlayBlur: 1.5, // Subtle blur effect
  );
}
