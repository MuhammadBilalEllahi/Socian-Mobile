import 'package:socian/pages/explore/SocietyProvider.dart';
import 'package:socian/pages/profile/settings/CreateSocietyPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/utils/constants.dart';
import 'package:socian/pages/profile/settings/ServerSelectionPage.dart';
import 'package:socian/pages/profile/settings/YourSocieties.dart';
import 'package:socian/pages/profile/settings/ModRequestPage.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Profile Section
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: user?['profile']?['picture'] != null
                      ? NetworkImage(user!['profile']['picture'])
                      : const AssetImage('assets/images/profilepic2.jpg')
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${user?['username'] ?? 'username'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Account Settings
          _buildSection(
            'Account',
            [
              _buildListTile(
                'Personal Information',
                Icons.person_outline,
                () {
                  // Navigate to personal info edit
                  Navigator.pushNamed(
                      context, AppRoutes.personalInfoEditScreen);
                },
                isDarkMode,
              ),
            ],
          ),

          _buildSection(
            'Societies',
            [
              _buildListTile(
                'Create a Society',
                Icons.people_alt_outlined,
                () {
                  // Navigate to personal info edit
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateSocietyPage()),
                  );
                },
                isDarkMode,
              ),
              _buildListTile(
                'Your Societies',
                Icons.people_alt_outlined,
                () {
                  // Navigate to personal info edit
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const YourSocieties()),
                  );
                },
                isDarkMode,
              ),
            ],
          ),
          // App Settings
          _buildSection(
            'Preferences',
            [
              _buildListTile(
                'Server Selection Disabled',
                Icons.cloud_outlined,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServerSelectionPage(),
                    ),
                  );
                },
                isDarkMode,
              ),
              _buildListTile(
                'Mod Request',
                Icons.person_add_alt_1_outlined,
                () {
                  // Navigate to personal info edit
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ModRequestPage()),
                  );
                },
                isDarkMode,
              ),
            ],
          ),

          // Help & About
          _buildSection(
            'Help & About',
            [
              _buildListTile(
                'Help Center',
                Icons.help_outline,
                () {
                  // Navigate to help center
                },
                isDarkMode,
              ),
              _buildListTile(
                'About ${AppConstants.appName}',
                Icons.info_outline,
                () {
                  // Navigate to about page
                },
                isDarkMode,
              ),
            ],
          ),

          // Account Actions
          _buildSection(
            'Account Actions',
            [
              // _buildListTile(
              //   'Switch Account',
              //   Icons.switch_account,
              //   () {
              //     // Handle account switching
              //   },
              //   isDarkMode,
              // ),
              _buildListTile(
                'Log Out',
                Icons.logout,
                () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    ref.invalidate(authProvider);
                    ref.invalidate(societiesProvider);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.authScreen,
                      (route) => false,
                    );
                  }
                },
                isDarkMode,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode, {
    bool isDestructive = false,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Icon(
        icon,
        size: 22,
        color: isDestructive
            ? Colors.red
            : (isDarkMode ? Colors.white : Colors.black),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDestructive
              ? Colors.red
              : (isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: isDarkMode ? Colors.white38 : Colors.black38,
      ),
      onTap: onTap,
    );
  }
}
