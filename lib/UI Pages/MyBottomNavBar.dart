

import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final double iconSize = 30;

  const MyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(25),
      // borderRadius: BorderRadius.circular(0),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
        // bottomRight: Radius.circular(30.0),
        // bottomLeft: Radius.circular(40.0),
      ),        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.2),
          //     blurRadius: 10,
          //     offset: const Offset(0, 5),
          //   ),
          // ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          // iconSize: 28,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_rounded,size: iconSize,),
              label: 'Feed',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.messenger_outline,size: iconSize,),
              label: 'Messages',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.people_outline,size: iconSize,),
              label: 'Explore',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.gps_fixed_rounded,size: iconSize,),
              label: 'GPS',
            ),
             BottomNavigationBarItem(
              icon: Icon(Icons.manage_accounts_sharp,size: iconSize,),
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

