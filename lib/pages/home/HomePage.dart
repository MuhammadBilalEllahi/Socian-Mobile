
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/bottomBar/MyBottomNavBar.dart';
import 'package:beyondtheclass/pages/explore/MapsPage.dart';
import 'package:beyondtheclass/pages/home/widgets/CampusPosts.dart';
import 'package:beyondtheclass/pages/message/Messages.dart';
import 'package:beyondtheclass/pages/profile/ProfilePage.dart';
import 'package:beyondtheclass/providers/page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  


  final ShorebirdUpdater updater = ShorebirdUpdater();
  bool _updateChecked = false;
late final Map<BottomNavBarRoute, Widget> _pages;


    @override
  void initState() {
    super.initState();
    _checkForUpdates();

    _pages = {
    // PostsPrimaryPage(),
    BottomNavBarRoute.home: const CampusPosts(),
    BottomNavBarRoute.message: const Messages(),
    BottomNavBarRoute.search: const Center(child: Text('Explore', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
    BottomNavBarRoute.explore: const MapsLook(),
    BottomNavBarRoute.profile: const ProfilePage(),
  };
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




  


  @override
  Widget build(BuildContext context) {

        final selectedRoute = ref.watch(pageIndexProvider);

    return Scaffold(
      extendBody: true,
      body: _pages[selectedRoute] ?? const Center(child: Text("Page Not Found")), // Display page based on selected index
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: selectedRoute.index,
        onItemTapped: (index) => ref.read(pageIndexProvider.notifier).state = BottomNavBarRoute.values[index],
      ),
    );
  }
}
