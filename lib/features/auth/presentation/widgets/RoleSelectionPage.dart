import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/presentation/student_signupScreen.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 48, 48, 48)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Select Your Role",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 28),),
            const SizedBox(height: 10,),
            _buildRoleCard(
              context,
              role: "Student",
              // icon: Icons.school,
              emoji: "🎓",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.signupScreenStudent
                );
                // Handle Student selection logic
                print("Student selected");
              },
            ),
            const SizedBox(height: 20),
            _buildRoleCard(
              context,
              role: "Faculty Member",
              // icon: Icons.person,
              emoji: "👩‍🏫",
              onTap: () {
                // Handle Faculty Member selection logic
                print("Faculty Member selected");
              },
            ),
            const SizedBox(height: 20),
            _buildRoleCard(
              context,
              role: "Alumni",
              // icon: Icons.group,
              emoji: "🧑‍🎓",
              onTap: () {
                // Handle Alumni selection logic
                print("Alumni selected");
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
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          // color: Colors.white,
          gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 42, 40, 40), Color.fromARGB(255, 69, 69, 69)],
                ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color.fromARGB(65, 255, 255, 255), 
          width: 0.6
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji or Icon
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 32, 32, 32), Color.fromARGB(255, 69, 69, 69)],
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(width: 15),
            // Role Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Select this if you are a $role.",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 170, 170, 170),
                    ),
                  ),
                ],
              ),
            ),
            // Icon

          ],
        ),
      ),
    );
  }
}
