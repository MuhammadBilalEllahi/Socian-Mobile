import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/providers/page_provider.dart';
import 'package:socian/shared/utils/constants.dart';

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
    final role = auth.user!['role'];
    String username = auth.user?['username'] ?? "";
    String picture = auth.user?['profile']?['picture'];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF5F5F5),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.2),
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
                  colors: isDarkMode
                      ? [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ]
                      : [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.05),
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
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.logout,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
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
                              colors: isDarkMode
                                  ? [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ]
                                  : [
                                      Colors.grey.withOpacity(0.2),
                                      Colors.grey.withOpacity(0.1),
                                    ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: isDarkMode
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey[200],
                            // child: Icon(
                            //   Icons.person,
                            //   size: 28,
                            //   color:
                            //       isDarkMode ? Colors.white70 : Colors.black54,
                            // ),

                            backgroundImage: picture != null
                                ? NetworkImage(picture)
                                : const AssetImage(
                                        "assets/images/profilepic2.jpg")
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '@$username',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: (isDarkMode
                                              ? Colors.white
                                              : Colors.black)
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 6, vertical: 2),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.amber,
                                  //     borderRadius: BorderRadius.circular(10),
                                  //   ),
                                  //   child: const Text(
                                  //     'PREMIUM',
                                  //     style: TextStyle(
                                  //       fontSize: 10,
                                  //       fontWeight: FontWeight.bold,
                                  //       color: Colors.black,
                                  //     ),
                                  //   ),
                                  // ),
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
            Divider(
                color: isDarkMode ? Colors.white24 : Colors.black12, height: 1),
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
                    isDarkMode: isDarkMode,
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: "Explore World",
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.alumniScrolls,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: "Moderators",
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.moderatorsPage,
                    ),
                    isDarkMode: isDarkMode,
                  ),
                  if (role == AppRoles.teacher)
                    _buildDrawerItem(
                      icon: Icons.rate_review,
                      title: "My Reviews",
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRoutes.selfReviewTeacher);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  if (role == AppRoles.student)
                    _buildDrawerItem(
                      icon: Icons.rate_review,
                      title: "Teacher's Reviews",
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRoutes.teacherReviewPage);
                      },
                      isDarkMode: isDarkMode,
                    ),
                  _buildDrawerItem(
                    icon: Icons.restaurant,
                    title: "Cafe Information Services",
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.cafeReviewsHome),
                    isDarkMode: isDarkMode,
                  ),
                  _buildDrawerItem(
                    icon: Icons.description,
                    title: "Past Papers",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.departmentScreen);
                    },
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateSocietyPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isDarkMode ? Colors.white : Colors.black,
                      width: 1,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18,
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Create Society",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              // margin: const EdgeInsets.only(bottom: 60),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 70),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [
                          Colors.grey.withOpacity(0.05),
                          Colors.grey.withOpacity(0.02),
                        ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withOpacity(0.5),
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
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white70 : Colors.black54,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
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
