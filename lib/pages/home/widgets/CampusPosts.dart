// import 'package:beyondtheclass/pages/drawer/MyDrawer.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import '../../../../components/PostCard.dart';

// import 'package:beyondtheclass/core/usecases/PostProvider.dart';
// import 'package:shimmer/shimmer.dart';

// class CampusPosts extends ConsumerStatefulWidget {
//   const CampusPosts({super.key});

//   @override
//   ConsumerState<CampusPosts> createState() => _CampusPostsState();
// }

// class _CampusPostsState extends ConsumerState<CampusPosts> with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     Future.microtask(() {
//       ref.read(postProvider.notifier).fetchPosts();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final postState = ref.watch(postProvider);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       drawer: const MyDrawer(),
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverAppBar(
//               backgroundColor: isDark ? Colors.black : Colors.white,
//               elevation: 0,
//               toolbarHeight: 60.0,
//               centerTitle: false,
//               title: Text(
//                 AppConstants.appName,
//                 style: TextStyle(
//                   color: isDark ? Colors.white : Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 24,
//                 ),
//               ),
//               automaticallyImplyLeading: false,
//               pinned: true,
//               leading: GestureDetector(
//                 onTap: () {
//                   Scaffold.of(context).openDrawer();
//                 },
//                 child: Icon(
//                   Icons.menu_outlined,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//               bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(48),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(
//                         color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
//                       ),
//                     ),
//                   ),
//                   child: TabBar(
//                     controller: _tabController,
//                     labelColor: isDark ? Colors.white : Colors.black,
//                     unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
//                     indicatorColor: isDark ? Colors.white : Colors.black,
//                     indicatorWeight: 3,
//                     tabs:  [
//                       Tab(
//                         text: 'Campus',
//                         child: const Text(
//                           'Campus',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       Tab(
//                         text: 'Universities',
//                         child: const Text(
//                           'Universities',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             // Campus Tab
//             RefreshIndicator(
//               onRefresh: () async {
//                 await ref.read(postProvider.notifier).fetchPosts();
//               },
//               child: _buildPostsList(postState, isDark),
//             ),
//             // Universities Tab
//             Center(
//               child: Text(
//                 'Coming Soon',
//                 style: TextStyle(
//                   color: isDark ? Colors.white : Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // TODO: Implement new post creation
//         },
//         backgroundColor: isDark ? Colors.white : Colors.black,
//         child: Icon(
//           Icons.add,
//           color: isDark ? Colors.black : Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _buildPostsList(PostProvider postState, bool isDark) {
//     if (postState.isLoading) {
//       return ListView.builder(
//         padding: EdgeInsets.zero,
//         itemCount: 5,
//         itemBuilder: (context, index) {
//           return Shimmer.fromColors(
//             baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
//             highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
//             child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//               height: 200,
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.grey[900] : Colors.white,
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     height: 50,
//                     margin: const EdgeInsets.all(12.0),
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[800] : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                   Container(
//                     height: 100,
//                     margin: const EdgeInsets.symmetric(horizontal: 12.0),
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[800] : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                   ),
//                   Container(
//                     height: 20,
//                     margin: const EdgeInsets.all(12.0),
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[800] : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(4.0),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }

//     if (postState.hasError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 60,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Error Loading Posts',
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               postState.errorMessage ?? 'Unknown error',
//               style: TextStyle(
//                 color: isDark ? Colors.grey[400] : Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (postState.posts.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.list,
//               color: isDark ? Colors.grey[600] : Colors.grey[400],
//               size: 60,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No Posts Available',
//               style: TextStyle(
//                 color: isDark ? Colors.white : Colors.black,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: EdgeInsets.zero,
//       itemCount: postState.posts.length,
//       itemBuilder: (context, index) {
//         final post = postState.posts[index];
//         return PostCard(
//           post: post,
//           postsBgColor: isDark ? Colors.black : Colors.white,
//           postsTextColor: isDark ? Colors.white : Colors.black,
//         );
//       },
//     );
//   }
// } 