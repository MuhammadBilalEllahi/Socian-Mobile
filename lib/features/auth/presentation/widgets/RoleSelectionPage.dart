import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/presentation/student_signupScreen.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Color.fromARGB(255, 0, 0, 0),
                    Color.fromARGB(255, 48, 48, 48)
                  ]
                : [
                    Color.fromARGB(255, 240, 240, 240),
                    Color.fromARGB(255, 255, 255, 255)
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Select Your Role",
              style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            const SizedBox(height: 10),
            _buildRoleCard(
              context,
              role: "Student",
              emoji: "🎓",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.signupScreen,
                  arguments: {
                    "role": AppRoles.student,
                  },
                );
                debugPrint("Student selected");
              },
            ),
            const SizedBox(height: 20),
            _buildRoleCard(
              context,
              role: "Faculty Member",
              emoji: "👩‍🏫",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.signupScreen,
                  arguments: {
                    "role": AppRoles.teacher,
                  },
                );
                debugPrint("Faculty Member selected");
              },
            ),
            const SizedBox(height: 20),
            _buildRoleCard(
              context,
              role: "Alumni",
              emoji: "🧑‍🎓",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.signupScreen,
                  arguments: {
                    "role": AppRoles.alumni,
                  },
                );
                debugPrint("Alumni selected");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required String emoji,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    Color.fromARGB(255, 42, 40, 40),
                    Color.fromARGB(255, 69, 69, 69)
                  ]
                : [
                    Color.fromARGB(255, 250, 250, 250),
                    Color.fromARGB(255, 230, 230, 230)
                  ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isDarkMode
                  ? const Color.fromARGB(65, 255, 255, 255)
                  : const Color.fromARGB(65, 0, 0, 0),
              width: 0.6),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [
                          Color.fromARGB(255, 32, 32, 32),
                          Color.fromARGB(255, 69, 69, 69)
                        ]
                      : [
                          Color.fromARGB(255, 240, 240, 240),
                          Color.fromARGB(255, 220, 220, 220)
                        ],
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Select this if you are a $role.",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? Color.fromARGB(255, 170, 170, 170)
                          : Color.fromARGB(255, 100, 100, 100),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
