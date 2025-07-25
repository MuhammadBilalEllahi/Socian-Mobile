// import 'package:socian/pages/gps/CreateNewGathering.dart';
// import 'package:socian/pages/gps/CreateNewGathering2.dart';
// import 'package:socian/pages/gps/GatheringsView.dart';
// import 'package:socian/pages/gps/MapMainPage.dart';
// import 'package:socian/pages/gps/ScheduledGatherings.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class GpsInitialPage extends StatefulWidget {
//   const GpsInitialPage({super.key});

//   @override
//   State<GpsInitialPage> createState() => _GpsInitialPageState();
// }

// class _GpsInitialPageState extends State<GpsInitialPage> {
//   @override
//   void initState() {
//     super.initState();
//     // Check location services and permissions when the page loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _checkLocationServicesAndPermissions();
//     });
//   }

//   Future<void> _checkLocationServicesAndPermissions() async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Show dialog to enable location services
//       await _showEnableLocationDialog();
//       return;
//     }

//     // Check location permission
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       // Request permission
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         // Show dialog for denied permission
//         await _showPermissionDeniedDialog();
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Show dialog for permanently denied permission
//       await _showPermissionPermanentlyDeniedDialog();
//       return;
//     }

//     // Permission granted (LocationPermission.always or LocationPermission.whileInUse)
//     // debugPrint('Location services enabled and permission granted');
//   }

//   Future<void> _showEnableLocationDialog() async {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: background,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(
//             color: muted,
//             width: 1,
//           ),
//         ),
//         title: Text(
//           'Enable Location Services',
//           style: TextStyle(
//             color: foreground,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Location services are disabled. Please enable location services to use GPS features.',
//           style: TextStyle(
//             color: foreground.withOpacity(0.7),
//             fontSize: 14,
//           ),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: foreground.withOpacity(0.7),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               backgroundColor: accent,
//               foregroundColor: foreground,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await Geolocator.openLocationSettings();
//               await _checkLocationServicesAndPermissions();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showPermissionDeniedDialog() async {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: background,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(
//             color: muted,
//             width: 1,
//           ),
//         ),
//         title: Text(
//           'Location Permission Required',
//           style: TextStyle(
//             color: foreground,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'This app needs location permission to function. Please grant location access.',
//           style: TextStyle(
//             color: foreground.withOpacity(0.7),
//             fontSize: 14,
//           ),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: foreground.withOpacity(0.7),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               backgroundColor: accent,
//               foregroundColor: foreground,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await _checkLocationServicesAndPermissions();
//             },
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showPermissionPermanentlyDeniedDialog() async {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: background,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(
//             color: muted,
//             width: 1,
//           ),
//         ),
//         title: Text(
//           'Location Permission Denied',
//           style: TextStyle(
//             color: foreground,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Location permissions are permanently denied. Please enable them in the app settings.',
//           style: TextStyle(
//             color: foreground.withOpacity(0.7),
//             fontSize: 14,
//           ),
//         ),
//         actions: [
//           TextButton(
//             style: TextButton.styleFrom(
//               foregroundColor: foreground.withOpacity(0.7),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               backgroundColor: accent,
//               foregroundColor: foreground,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             onPressed: () async {
//               Navigator.of(context).pop();
//               await Geolocator.openAppSettings();
//               await _checkLocationServicesAndPermissions();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

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
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [

//                 _buildNavigationCard(
//                   context,
//                   title: 'Scheduled Gatherings',
//                   description: 'Join a scheduled gathering',
//                   icon: Icons.group,
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ScheduledGatherings(),
//                     ),
//                   ),
//                   background: background,
//                   foreground: foreground,
//                   muted: muted,
//                   border: border,
//                 ),
//                 const SizedBox(height: 24),
//                 _buildNavigationCard(
//                   context,
//                   title: 'Schedule a New Gathering',
//                   description: 'Mark a new gathering to notify others',
//                   icon: Icons.event,
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const CreateNewGathering2(),
//                     ),
//                   ),
//                   background: background,
//                   foreground: foreground,
//                   muted: muted,
//                   border: border,
//                 ),
//                 const SizedBox(height: 24),
//                 _buildNavigationCard(
//                   context,
//                   title: 'See Gatherings View',
//                   description: 'See current gatherings on the map',
//                   icon: Icons.map,
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const GatheringsView(),
//                     ),
//                   ),
//                   background: background,
//                   foreground: foreground,
//                   muted: muted,
//                   border: border,
//                 ),
//                 SizedBox(height: 100,),

//               ],
//             ),
//           ),
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

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socian/pages/gps/CreateNewGathering2.dart';
import 'package:socian/pages/gps/GatheringsView.dart';
import 'package:socian/pages/gps/ScheduledGatherings.dart';

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
    // debugPrint('Location services enabled and permission granted');
  }

  Future<void> _showEnableLocationDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: muted,
            width: 1,
          ),
        ),
        title: Text(
          'Enable Location Services',
          style: TextStyle(
            color: foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Location services are disabled. Please enable location services to use GPS features.',
          style: TextStyle(
            color: foreground.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: foreground.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: foreground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
              await _checkLocationServicesAndPermissions();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: muted,
            width: 1,
          ),
        ),
        title: Text(
          'Location Permission Required',
          style: TextStyle(
            color: foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This app needs location permission to function. Please grant location access.',
          style: TextStyle(
            color: foreground.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: foreground.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: foreground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _checkLocationServicesAndPermissions();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionPermanentlyDeniedDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: muted,
            width: 1,
          ),
        ),
        title: Text(
          'Location Permission Denied',
          style: TextStyle(
            color: foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Location permissions are permanently denied. Please enable them in the app settings.',
          style: TextStyle(
            color: foreground.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: foreground.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: foreground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
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
    final premiumColor =
        isDarkMode ? const Color(0xFFFFD700) : const Color(0xFFD4AF37);

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNavigationCard(
                  context,
                  title: 'Scheduled Gatherings',
                  description: 'Join a scheduled gathering',
                  icon: Icons.group,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScheduledGatherings(),
                    ),
                  ),
                  background: background,
                  foreground: foreground,
                  muted: muted,
                  border: border,
                ),
                const SizedBox(height: 24),
                _buildNavigationCard(
                  context,
                  title: 'See Gatherings View',
                  description: 'See current gatherings on the map',
                  icon: Icons.map,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GatheringsView(),
                    ),
                  ),
                  background: background,
                  foreground: foreground,
                  muted: muted,
                  border: border,
                ),

                // Spacer to push the premium card to the bottom
                const SizedBox(height: 24),

                // Divider with text
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: border,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Organizer Tools',
                          style: TextStyle(
                            color: mutedForeground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: border,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Premium moderator card
                _buildPremiumNavigationCard(
                  context,
                  title: 'Schedule a New Gathering',
                  description: 'Create and manage gatherings for members',
                  icon: Icons.event,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateNewGathering2(),
                    ),
                  ),
                  background: background,
                  foreground: foreground,
                  muted: muted,
                  border: border,
                  premiumColor: premiumColor,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildPremiumNavigationCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required Color background,
    required Color foreground,
    required Color muted,
    required Color border,
    required Color premiumColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: premiumColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: premiumColor.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
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
                    color: premiumColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: premiumColor,
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
                  color: premiumColor,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: premiumColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Organizer Access',
                  style: TextStyle(
                    color: premiumColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
