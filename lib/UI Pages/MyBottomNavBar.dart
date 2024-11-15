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
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)
        ),



        child: BottomNavigationBar(

          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.teal[200],
          fixedColor: Colors.white,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.messenger_outline),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Societies',
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
          // selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.black,

          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
