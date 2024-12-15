import 'package:beyondtheclass/UI%20Pages/Messages.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/UI%20Pages/MyBottomNavBar.dart';
import 'package:beyondtheclass/UI%20Pages/Map.dart';

import 'PostsPrimaryPage.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Define your pages here
  static const List<Widget> _pages = <Widget>[
    PostsPrimaryPage(),
    Messages(),
    Center(child: Text('Explore', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    Map(),
    ProfilePage(),
  ];

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex], // Display page based on selected index
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavBarTapped,
      ),
    );
  }
}
