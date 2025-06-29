// import 'package:socian/shared/utils/constants.dart';
// import 'package:socian/pages/bottomBar/MyBottomNavBar.dart';
// import 'package:socian/pages/explore/ExploreSocieities.dart';
// import 'package:socian/pages/gps/GpsInitialPage.dart';
// import 'package:socian/pages/home/widgets/AllView.dart';
// import 'package:socian/pages/message/Messages.dart';
// import 'package:socian/pages/profile/ProfilePage.dart';
// import 'package:socian/pages/providers/page_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:socian/features/auth/providers/auth_provider.dart';

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
