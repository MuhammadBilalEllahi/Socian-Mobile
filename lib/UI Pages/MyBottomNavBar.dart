import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final double iconSize = 30;
  final double selected_iconSize = 22;

  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(),
      child: Container(
        
        decoration: Theme.of(context).brightness == Brightness.dark 
        
        ? BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade900, 
              Colors.teal.shade400
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        )
        : BoxDecoration(
      gradient: LinearGradient(
      colors: [
        Colors.teal, 
        Colors.teal.shade100
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      ),
    ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Text(
                "📰",
                style: TextStyle(
                  fontSize: selectedIndex == 0 ? selected_iconSize : iconSize, // Increase size when selected
                ),
              ),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Text(
                "✉️",
                style: TextStyle(
                  fontSize: selectedIndex == 1 ? selected_iconSize : iconSize, // Increase size when selected
                ),
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Text(
                "👬🏻",
                style: TextStyle(
                  fontSize: selectedIndex == 2 ? selected_iconSize : iconSize, // Increase size when selected
                ),
              ),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Text(
                "🗺️",
                style: TextStyle(
                  fontSize: selectedIndex == 3 ? selected_iconSize : iconSize, // Increase size when selected
                ),
              ),
              label: 'GPS',
            ),
            BottomNavigationBarItem(
              icon: Text(
                "👦🏻",
                style: TextStyle(
                  fontSize: selectedIndex == 4 ? selected_iconSize : iconSize, // Increase size when selected
                ),
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
