import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import '../../../components/PostCard.dart';
import '../../drawer/MyDrawer.dart';
import 'package:beyondtheclass/core/usecases/PostProvider.dart'; // Import your PostProvider

class CampusPosts extends ConsumerWidget { // Use ConsumerWidget instead of StatefulWidget
  const CampusPosts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the PostProvider instance correctly
    final postState = ref.watch(postProvider); // Rename the variable to avoid conflict

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
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh posts manually
          await ref.read(postProvider.notifier).fetchPosts();
        },
        child: CustomScrollView(
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
                                // Handle logout
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
            if (postState.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
              )
            else if (postState.hasError)
              SliverFillRemaining(
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
                      Text(postState.errorMessage ?? 'Unknown error', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              )
            else if (postState.posts.isEmpty)
                SliverFillRemaining(
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
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = postState.posts[index];
                      return PostCard(
                        post: post,
                        postsBgColor: postsBgColor,
                        postsTextColor: postsTextColor,
                      );
                    },
                    childCount: postState.posts.length,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}