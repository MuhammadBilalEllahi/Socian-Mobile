import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/PostCard.dart';
import 'MyDrawer.dart';
import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';

class CampusPosts extends ConsumerWidget {
  const CampusPosts({super.key});

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

    Color postsBgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // for dark mode
        : Colors.tealAccent.shade700; // for light mode

    Color postsTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    Color titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.teal;

    Color topIconsColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      drawer: const MyDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 23.0,
            centerTitle: false,
            title: Text(AppConstants.appName, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold)),
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
                            child: SizedBox(
                              width: 40,
                              child: Icon(Icons.menu_outlined, color: topIconsColor),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: topIconsColor),
                            onPressed: () {
                              ref.read(authProvider.notifier).logout(); // Use ref here for logout
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AuthScreen(),
                                ),
                              );
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
            future: fetchPosts(), // Trigger this function directly
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
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
                        Text('${snapshot.error}', style: Theme.of(context).textTheme.bodySmall),
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
                      return PostCard(
                        post: post,
                        postsBgColor: postsBgColor,
                        postsTextColor: postsTextColor,
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
