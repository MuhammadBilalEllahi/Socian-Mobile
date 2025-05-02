// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:beyondtheclass/pages/bottomBar/MyBottomNavBar.dart';
// import 'package:beyondtheclass/pages/explore/ExploreSocieities.dart';
// import 'package:beyondtheclass/pages/gps/GpsInitialPage.dart';
// import 'package:beyondtheclass/pages/home/widgets/AllView.dart';
// import 'package:beyondtheclass/pages/message/Messages.dart';
// import 'package:beyondtheclass/pages/profile/ProfilePage.dart';
// import 'package:beyondtheclass/pages/providers/page_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';

// class TeacherHome extends ConsumerStatefulWidget {
//   const TeacherHome({super.key});

//   @override
//   _TeacherHomeState createState() => _TeacherHomeState();
// }

// class _TeacherHomeState extends ConsumerState<TeacherHome> {
//   late final Map<BottomNavBarRoute, Widget> _pages;

//   @override
//   void initState() {
//     super.initState();

//     _pages = {
//       BottomNavBarRoute.home: const AllView(),
//       BottomNavBarRoute.message: const Messages(),
//       BottomNavBarRoute.explore: const ExploreSocieties(),
//       BottomNavBarRoute.gps: const GpsInitialPage(),
//       BottomNavBarRoute.profile: const ProfilePage(),
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authProvider);
//     final user = auth.user;

//     final selectedRoute = ref.watch(pageIndexProvider);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       extendBody: true,
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       body:
//           _pages[selectedRoute] ?? const Center(child: Text("Page Not Found")),
//       bottomNavigationBar: MyBottomNavBar(
//         selectedIndex: selectedRoute.index,
//         onItemTapped: (index) => ref.read(pageIndexProvider.notifier).state =
//             BottomNavBarRoute.values[index],
//       ),
//     );
//   }
// }
