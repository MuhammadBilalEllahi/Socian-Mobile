import 'package:beyondtheclass/pages/gps/CreateNewGathering.dart';
import 'package:beyondtheclass/pages/gps/ScheduledGatherings.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/pages/gps/MapMainPage.dart';

class GpsInitialPage extends StatelessWidget {
  const GpsInitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'GPS Navigation',
          style: TextStyle(
            color: foreground,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: background,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                                       
                    _buildNavigationCard(
                      context,
                      title: 'Call a Meeting',
                      description: 'Create a meeting point and invite others',
                      icon: Icons.group,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MapMainPage()),
                      ),
                      background: background,
                      foreground: foreground,
                      muted: muted,
                      border: border,
                    ),
                    const SizedBox(height: 24),
                    _buildNavigationCard(
                      context,
                      title: 'Scheduled Gatherings',
                      description: 'Join a scheduled gathering',
                      icon: Icons.group,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  ScheduledGatherings()),
                      ),
                      background: background,
                      foreground: foreground,
                      muted: muted,
                      border: border,
                    ),
                      const SizedBox(height: 24),
                    _buildNavigationCard(
                      context,
                      title: 'Schedule a New Gathering',
                      description: 'Mark a new gathering to notify others',
                      icon: Icons.group,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  CreateNewGathering()),
                      ),
                      background: background,
                      foreground: foreground,
                      muted: muted,
                      border: border,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildNavigationCard(
  BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
  required VoidCallback onTap,
  required Color background,
  required Color foreground,
  required Color muted,
  required Color border,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: foreground,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: foreground.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: foreground.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
