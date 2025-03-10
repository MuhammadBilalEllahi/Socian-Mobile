import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/auth_screen.dart';
import '../../../../features/auth/providers/auth_provider.dart';

class ProfileDropDown extends ConsumerWidget {
  const ProfileDropDown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    const primary = Color(0xFF8B5CF6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<int>(
          icon: Icon(Icons.more_horiz, color: foreground),
          color: isDarkMode ? const Color(0xFF18181B) : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            ),
          ),
          onSelected: (value) {
            switch (value) {
              case 1:
                print("View Profile");
                break;
              case 2:
                print("Edit Profile");
                break;
              case 3:
                print("Settings");
                break;
              case 4:
                ref.read(authProvider.notifier).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  const Icon(Icons.person, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    "View Profile",
                    style: TextStyle(color: foreground),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  const Icon(Icons.edit, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    "Edit Profile",
                    style: TextStyle(color: foreground),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  const Icon(Icons.settings, color: primary),
                  const SizedBox(width: 8),
                  Text(
                    "Settings",
                    style: TextStyle(color: foreground),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Color(0xFFEC4899)),
                  const SizedBox(width: 8),
                  Text(
                    "Logout",
                    style: TextStyle(color: foreground),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}