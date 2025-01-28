// import 'package:flutter/material.dart';
// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'MyDrawer.dart';
// import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:beyondtheclass/UI%20Pages/MyDrawer.dart';
// import 'package:beyondtheclass/UI%20Pages/SimplePost.dart';
// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import 'BreakingNewsScroller.dart';
// import 'Filters.dart';
// import 'QnA Post Widgets/QnAPost.dart';
//
//
// class CampusPosts extends StatefulWidget {
//   const CampusPosts({super.key});
//
//   @override
//   _CampusPostsState createState() => _CampusPostsState();
// }
//
// class _CampusPostsState extends State<CampusPosts> {
//   late Future<List<dynamic>> posts = Future.value([]);
//   final ApiClient apiClient = ApiClient();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPosts();
//   }
//
//   void fetchPosts() async {
//     try {
//       final response = await apiClient.get(ApiConstants.postsCampus); // Replace with the correct endpoint
//
//       print("API Response: $response"); // Print the entire response to inspect
//       print("Response type: ${response.runtimeType}"); // Print the type of the response to verify it
//
//       // Check if response is a List
//       if (response is List) {
//         setState(() {
//           posts = Future.value(response); // Directly assign the list of posts
//         });
//       } else {
//         setState(() {
//           posts = Future.error('Invalid API response format: $response');
//         });
//       }
//     } catch (e) {
//       setState(() {
//         posts = Future.error('Failed to load posts: $e');
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const MyDrawer(),
//       body: CustomScrollView(
//         slivers: [
//
//
//           SliverAppBar(
//             backgroundColor: Colors.transparent,
//             toolbarHeight: 23.0,
//             centerTitle: false,
//             title: Text( AppConstants.appName, style: TextStyle(color: Colors.teal[800],fontWeight: FontWeight.bold)),
//             automaticallyImplyLeading: false,
//             pinned: false, // This line makes the app bar scroll
//           ),
//
//           SliverToBoxAdapter(
//             child: Builder(
//               builder: (BuildContext context) {
//                 return Column(
//                   children: [
//                     SizedBox(
//                       height: 50,
//                       // color: Colors.brown,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Scaffold.of(context).openDrawer();
//                             },
//                             child: const SizedBox(
//                               width: 40,
//                               // color: Colors.green,
//                               child: Icon(Icons.menu_outlined),
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.logout),
//                                 onPressed: () {
//                                   // ref.read(authProvider.notifier).logout();
//                                   Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                           const AuthScreen()));
//                                 },
//                               ),
//
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
//                       child: SizedBox(
//                         height: 50,
//                         // color: Colors.red,
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Row(
//                             children: [
//
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                   ],
//                 );
//               },
//             ),
//           ),
//
//
//
//           FutureBuilder<List<dynamic>>(
//             future: posts,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const SliverFillRemaining(
//                   hasScrollBody: false,
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                     ),
//                   ),
//                 );
//               } else if (snapshot.hasError) {
//                 return SliverFillRemaining(
//                   hasScrollBody: false,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.error_outline, color: Colors.red, size: 60),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Error Loading Posts',
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         Text('${snapshot.error}',
//                             style: Theme.of(context).textTheme.bodySmall),
//                       ],
//                     ),
//                   ),
//                 );
//               } else if (snapshot.data?.isEmpty ?? true) {
//                 return SliverFillRemaining(
//                   hasScrollBody: false,
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.list, color: Colors.grey, size: 60),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No Posts Available',
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               } else {
//                 final postList = snapshot.data!;
//                 return SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                       final post = postList[index];
//                       return Card(
//                         elevation: 5,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         margin: const EdgeInsets.symmetric(vertical: 12),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.teal.shade900,
//                                 Colors.tealAccent.shade400,
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(12),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     CircleAvatar(
//                                       backgroundColor: Colors.white,
//                                       backgroundImage: post['author'] != null && post['author']['profile'] != null
//                                           ? NetworkImage(post['author']['profile']['picture'] ?? '')
//                                           : AssetImage('assets/default_profile_picture.png'), // Default image if null
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: Text(
//                                         post['title'] ?? 'Untitled',
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .titleMedium
//                                             ?.copyWith(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     const Icon(
//                                       Icons.more_vert,
//                                       color: Colors.white,
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   post['body'] ?? 'No body available',
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .bodySmall
//                                       ?.copyWith(color: Colors.white70),
//                                   maxLines: 4,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.favorite_border,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                         const SizedBox(width: 6),
//                                         Text(
//                                           'Like',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodySmall
//                                               ?.copyWith(color: Colors.white),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.comment,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                         const SizedBox(width: 6),
//                                         Text(
//                                           'Comment',
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodySmall
//                                               ?.copyWith(color: Colors.white),
//                                         ),
//                                       ],
//                                     ),
//                                     Text(
//                                       '2 hours ago',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall
//                                           ?.copyWith(color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     childCount: postList.length,
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//









import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'MyDrawer.dart';
import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'BreakingNewsScroller.dart';
import 'Filters.dart';
import 'QnA Post Widgets/QnAPost.dart';

class CampusPosts extends ConsumerWidget {
  const CampusPosts({super.key});

  // Function to fetch posts
  Future<List<dynamic>> fetchPosts() async {
    final ApiClient apiClient = ApiClient();
    try {
      final response = await apiClient.get(ApiConstants.postsCampus); // Use the correct API endpoint

      if (response is List) {
        return response; // Return the list of posts
      } else {
        throw 'Invalid API response format: $response';
      }
    } catch (e) {
      throw 'Failed to load posts: $e'; // Handle the error
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const MyDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 23.0,
            centerTitle: false,
            title: Text(AppConstants.appName, style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: false,
            pinned: false,
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: const SizedBox(
                              width: 40,
                              child: Icon(Icons.menu_outlined),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();  // Use ref here for logout
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AuthScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: fetchPosts(), // Trigger fetchPosts function directly
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Posts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('${snapshot.error}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.data?.isEmpty ?? true) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.list, color: Colors.grey, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'No Posts Available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                final postList = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = postList[index];
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.teal.shade900,
                                Colors.tealAccent.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: post['author'] != null && post['author']['profile'] != null
                                          ? NetworkImage(post['author']['profile']['picture'] ?? '')
                                          : AssetImage('assets/default_profile_picture.png'), // Default image if null
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        post['title'] ?? 'Untitled',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post['body'] ?? 'No body available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white70),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite_border,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Like',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.comment,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Comment',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '2 hours ago',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: postList.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

