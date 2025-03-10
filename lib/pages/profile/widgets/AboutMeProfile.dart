import 'package:flutter/material.dart';

class AboutMeProfile extends StatefulWidget {
  const AboutMeProfile({super.key});

  @override
  State<AboutMeProfile> createState() => _AboutMeProfileState();
}

class _AboutMeProfileState extends State<AboutMeProfile> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: border,
            width: 1,
          ),
        ),
        width: screenWidth / 1.1,
        height: 200,
        child: Center(
          child: Text(
            "Welcome To My Profile. Lorem Ipsum este pur şi simplu o machetă pentru text a industriei tipografice.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
