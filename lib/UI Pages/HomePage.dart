import 'package:beyondtheclass/UI%20Pages/Messages.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/UI%20Pages/MyBottomNavBar.dart';
import 'package:beyondtheclass/UI%20Pages/Map.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import 'PostsPrimaryPage.dart';
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;


  final ShorebirdUpdater updater = ShorebirdUpdater();
  bool _updateChecked = false;



    @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    if (_updateChecked) return; // Prevent duplicate checks
    _updateChecked = true;

    final status = await updater.checkForUpdate();

    if (status == UpdateStatus.outdated) {
      await _showUpdateModal();
      try {
        await updater.update();
      } on UpdateException catch (error) {
        print("Error during update: $error");
      }
      await _showPostUpdateModal();
    }
  }

  Future<void> _showUpdateModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("App Update Available"),
          content: const Text(
            "A new update is available. The app will be updated when you restart it.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPostUpdateModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("App Updated"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Thank you for updating the app!"),
              SizedBox(height: 10),
              Text("New Features Include:"),
              SizedBox(height: 10),
              Text("- Improved performance"),
              Text("- Bug fixes"),
              Text("- Exciting new functionalities"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it!"),
            ),
          ],
        );
      },
    );
  }












  // Define your pages here
  static const List<Widget> _pages = <Widget>[
    PostsPrimaryPage(),
    Messages(),
    Center(child: Text('Explore', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    MapsLook(),
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
