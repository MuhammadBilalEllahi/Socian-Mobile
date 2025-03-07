import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/StudentPages/home/widgets/campus/CampusPosts.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/drawer/student/pages/pastPaper/DepartmentPage.dart';
import 'package:beyondtheclass/pages/drawer/student/pages/teachersReviews/TeachersPage.dart';
import 'package:beyondtheclass/providers/page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentDrawer extends ConsumerStatefulWidget {
  const StudentDrawer({super.key});

  @override
  _StudentDrawerState createState() => _StudentDrawerState();
}

class _StudentDrawerState extends ConsumerState<StudentDrawer> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    String name = auth.user?['name'] ?? "";
    String username = auth.user?['username'] ?? "";

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
          decoration: BoxDecoration(
          gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2D2D2D),
                    ],
            ),
            boxShadow: [
              BoxShadow(
              color: Colors.black.withValues(alpha:0.2),
              blurRadius: 20,
              spreadRadius: 5,
              ),
            ],
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha:0.1),
                    Colors.white.withValues(alpha:0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          ref.watch(authProvider.notifier).logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.authScreen,
                            (route) => false,
                          );
                        },
                  ),
                ],
              ),
                  const SizedBox(height: 16),
                  // Profile Section
                  GestureDetector(
                    onTap: () => ref.read(pageIndexProvider.notifier).state =
                        BottomNavBarRoute.profile,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha:0.2),
                                Colors.white.withValues(alpha:0.1),
                              ],
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFF2A2A2A),
                          child: Icon(
                            Icons.person,
                              size: 28,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                              Text(
                                    '@$username',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha:0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'PREMIUM',
                                      style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_filled,
                    title: "Home",
                    onTap: () => ref.read(pageIndexProvider.notifier).state =
                        BottomNavBarRoute.home,
                  ),
                  // _buildDrawerItem(
                  //   icon: Icons.school,
                  //   title: "All Universities",
                  //   onTap: () => Navigator.of(context).pop(),
                  // ),
                  _buildDrawerItem(
                    icon: Icons.location_city,
                    title: "Inter Campuses",
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: "Alumni",
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.rate_review,
                    title: "Teacher's Reviews",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeachersPage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.restaurant,
                    title: "Cafe Information Services",
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _buildDrawerItem(
                    icon: Icons.description,
                    title: "Past Papers",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DepartmentPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha:0.05),
                    Colors.white.withValues(alpha:0.02),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Beyond The Class',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha:0.5),
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

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white70,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      dense: true,
      visualDensity: const VisualDensity(vertical: 0),
    );
  }
}
