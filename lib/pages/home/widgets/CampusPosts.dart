import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import '../../../components/PostCard.dart';
import '../../drawer/MyDrawer.dart';
import 'package:beyondtheclass/core/usecases/PostProvider.dart'; // Import your PostProvider

class CampusPosts extends ConsumerStatefulWidget {
  const CampusPosts({super.key});

  @override
  ConsumerState<CampusPosts> createState() => _CampusPostsState();
}

class _CampusPostsState extends ConsumerState<CampusPosts> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postProvider.notifier).fetchPosts(); // Ensures this runs only once
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the PostProvider instance correctly

    // ref.listen(postProvider, (previous, next) {
    //   if (previous == null) {
    //     ref.read(postProvider.notifier).fetchPosts(); // Fetch only once when initialized
    //   }
    // });

    final postState = ref.watch(postProvider); // Rename the variable to avoid conflict

    Color postsBgColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 203, 203, 203) // for dark mode
        : const Color.fromARGB(255, 61, 61, 61); // for light mode

    Color postsTextColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 221, 221, 221)
        : const Color.fromARGB(255, 70, 70, 70);

    Color titleColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 210, 210, 210)
        : const Color.fromARGB(255, 56, 56, 56);

    Color topIconsColor = Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 219, 219, 219)
        : const Color.fromARGB(255, 43, 43, 43);

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
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 24, 24, 24)),
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