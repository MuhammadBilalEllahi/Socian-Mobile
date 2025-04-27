// import 'package:beyondtheclass/pages/gps/CreateNewGathering.dart';
// import 'package:beyondtheclass/pages/gps/ScheduledGatherings.dart';
// import 'package:flutter/material.dart';
// import 'package:beyondtheclass/pages/gps/MapMainPage.dart';

// class GpsInitialPage extends StatelessWidget {
//   const GpsInitialPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted =
//         isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final mutedForeground =
//         isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border =
//         isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent =
//         isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: background,
//         elevation: 0,
//         title: Text(
//           'GPS Navigation',
//           style: TextStyle(
//             color: foreground,
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         color: background,
//         child: Column(
//           children: [
//             Expanded(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
                                       
//                     _buildNavigationCard(
//                       context,
//                       title: 'Call a Meeting',
//                       description: 'Create a meeting point and invite others',
//                       icon: Icons.group,
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const MapMainPage()),
//                       ),
//                       background: background,
//                       foreground: foreground,
//                       muted: muted,
//                       border: border,
//                     ),
//                     const SizedBox(height: 24),
//                     _buildNavigationCard(
//                       context,
//                       title: 'Scheduled Gatherings',
//                       description: 'Join a scheduled gathering',
//                       icon: Icons.group,
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>  ScheduledGatherings()),
//                       ),
//                       background: background,
//                       foreground: foreground,
//                       muted: muted,
//                       border: border,
//                     ),
//                       const SizedBox(height: 24),
//                     _buildNavigationCard(
//                       context,
//                       title: 'Schedule a New Gathering',
//                       description: 'Mark a new gathering to notify others',
//                       icon: Icons.group,
//                       onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) =>  CreateNewGathering()),
//                       ),
//                       background: background,
//                       foreground: foreground,
//                       muted: muted,
//                       border: border,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget _buildNavigationCard(
//   BuildContext context, {
//   required String title,
//   required String description,
//   required IconData icon,
//   required VoidCallback onTap,
//   required Color background,
//   required Color foreground,
//   required Color muted,
//   required Color border,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: border),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: muted,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: foreground,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: foreground,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       description,
//                       style: TextStyle(
//                         color: foreground.withOpacity(0.7),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: foreground.withOpacity(0.5),
//                 size: 16,
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }


import 'package:beyondtheclass/pages/gps/CreateNewGathering.dart';
import 'package:beyondtheclass/pages/gps/ScheduledGatherings.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/pages/gps/MapMainPage.dart';
import 'package:geolocator/geolocator.dart';

class GpsInitialPage extends StatefulWidget {
  const GpsInitialPage({super.key});

  @override
  State<GpsInitialPage> createState() => _GpsInitialPageState();
}

class _GpsInitialPageState extends State<GpsInitialPage> {
  @override
  void initState() {
    super.initState();
    // Check location services and permissions when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationServicesAndPermissions();
    });
  }

  Future<void> _checkLocationServicesAndPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show dialog to enable location services
      await _showEnableLocationDialog();
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show dialog for denied permission
        await _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show dialog for permanently denied permission
      await _showPermissionPermanentlyDeniedDialog();
      return;
    }

    // Permission granted (LocationPermission.always or LocationPermission.whileInUse)
    print('Location services enabled and permission granted');
  }

  Future<void> _showEnableLocationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Services'),
        content: const Text(
          'Location services are disabled. Please enable location services to use GPS features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Open location settings
              await Geolocator.openLocationSettings();
              // Re-check after returning
              await _checkLocationServicesAndPermissions();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location permission to function. Please grant location access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Re-request permission
              await _checkLocationServicesAndPermissions();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Location permissions are permanently denied. Please enable them in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Open app settings
              await Geolocator.openAppSettings();
              // Re-check after returning
              await _checkLocationServicesAndPermissions();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

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
                            builder: (context) => const ScheduledGatherings()),
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
                            builder: (context) => const CreateNewGathering()),
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