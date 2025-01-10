import 'package:beyondtheclass/features/auth/presentation/student_signupScreen.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.tealAccent.shade400],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const signup_screen()),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.teal[300]!, Colors.teal],
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
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Select this if you are a $role.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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
