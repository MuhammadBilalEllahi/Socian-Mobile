
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
import 'package:url_launcher/url_launcher.dart';

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
      BottomNavBarRoute.home: const CampusPosts(),
      BottomNavBarRoute.message: const Messages(),
      BottomNavBarRoute.search: const Center(child: Text('Explore', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
      BottomNavBarRoute.explore: const MapsLook(),
      BottomNavBarRoute.profile: const ProfilePage(),
    };
  }

  Future<void> _checkForUpdates() async {
    if (_updateChecked) return;
    _updateChecked = true;

    final status = await updater.checkForUpdate();
    debugPrint("Update status: $status"); // Debug print

    if (status == UpdateStatus.restartRequired) {
      await _showInAppUpdateModal();
    } else if (status == UpdateStatus.upToDate) {
      // Handle up to date case
    } else if(status == UpdateStatus.outdated) {
      await _showPlayStoreUpdateModal();
    }
  }

  Future<void> _showInAppUpdateModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.system_update,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick Update Available",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Updates instantly - No Play Store needed",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "What's new:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUpdatePoint("• Enhanced performance and stability"),
                _buildUpdatePoint("• New features and improvements"),
                _buildUpdatePoint("• Bug fixes and optimizations"),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: Colors.grey[800]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Later",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await updater.update();
                            if (mounted) {
                              Navigator.pop(context);
                              _showUpdateSuccessModal();
                            }
                          } catch (e) {
                            debugPrint("Update error: $e");
                            _showUpdateErrorModal();
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Update Now",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPlayStoreUpdateModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Major Update Required",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please update the app from Play Store to continue using the latest features",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      final url = Uri.parse('market://details?id=com.beyondtheclass.app');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        // Fallback to web URL if market URL fails
                        await launchUrl(
                          Uri.parse('https://play.google.com/store/apps/details?id=com.beyondtheclass.app')
                        );
                      }
                      // Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Go to Play Store",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showUpdateSuccessModal() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Update successfully installed!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showUpdateErrorModal() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to install update. Please try again later."),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildUpdatePoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoute = ref.watch(pageIndexProvider);

    return Scaffold(
      extendBody: true,
      body: _pages[selectedRoute] ?? const Center(child: Text("Page Not Found")),
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: selectedRoute.index,
        onItemTapped: (index) => ref.read(pageIndexProvider.notifier).state = BottomNavBarRoute.values[index],
      ),
    );
  }
}
