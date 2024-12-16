

import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade900, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, // Transparent to show gradient
            elevation: 0, // Remove elevation
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            iconSize: 28,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper_rounded),
                label: 'Feed',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.messenger_outline),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.gps_fixed_rounded),
                label: 'GPS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.manage_accounts_sharp),
                label: 'Profile',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: onItemTapped,
          ),
        ),
      ),
    );
  }
}

