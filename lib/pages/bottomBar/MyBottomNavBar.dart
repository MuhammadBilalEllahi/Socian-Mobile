import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final double iconSize = 30;
  final double selectedIconSize = 22;

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
        
        ? const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 27, 27, 27), 
              Color.fromARGB(255, 29, 29, 29)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        )
        : const BoxDecoration(
      gradient: LinearGradient(
      colors: [
        Color.fromARGB(255, 219, 219, 219), 
        Colors.white
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      ),
    ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).iconTheme.color,
          unselectedItemColor: Theme.of(context).iconTheme.color,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_filled,
                size:  selectedIndex == 0 ? selectedIconSize : iconSize, // Increase size when selected
              ),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.messenger_outline_sharp,
                size:  selectedIndex == 1 ? selectedIconSize : iconSize, // Increase size when selected
              ),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                size:  selectedIndex == 2 ? selectedIconSize : iconSize, // Increase size when selected
              ),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.explore_outlined,
                size:  selectedIndex == 3 ? selectedIconSize : iconSize, // Increase size when selected
              ),
              label: 'GPS',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline_outlined,
                size:  selectedIndex == 4 ? selectedIconSize : iconSize, // Increase size when selected
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
