import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/auth_screen.dart';
import '../../../features/auth/providers/auth_provider.dart';

class ProfileDropDown extends ConsumerWidget{
  const ProfileDropDown({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<int>(
          icon: const Icon(Icons.more_horiz),
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
                print("Logout");

                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.teal),
                  SizedBox(width: 8),
                  Text("View Profile"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Edit Profile"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Settings"),
                ],
              ),
            ),
            const PopupMenuItem(

              value: 4,
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Logout"),
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