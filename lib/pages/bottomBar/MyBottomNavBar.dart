import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final double iconSize = 26;
  final double selectedIconSize = 26;

  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: isDark ? Colors.white : Colors.black,
          unselectedItemColor: isDark
              ? Colors.white.withOpacity(0.5)
              : Colors.black.withOpacity(0.5),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
                size: selectedIndex == 0 ? selectedIconSize : iconSize,
              ),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.security_update_good_outlined,
                size: selectedIndex == 1 ? selectedIconSize : iconSize,
              ),
              label: 'Updates',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search_rounded,
                size: selectedIndex == 2 ? selectedIconSize : iconSize,
              ),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.explore_rounded,
                size: selectedIndex == 3 ? selectedIconSize : iconSize,
              ),
              label: 'GPS',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_rounded,
                size: selectedIndex == 4 ? selectedIconSize : iconSize,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
