// import 'package:socian/services/user_info_provider.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socian/components/effects/ShiningLinearProgressBar.dart';
import 'package:socian/pages/home/widgets/intracampus/intraCampusProvider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';

import '../components/post/post.dart';

class IntraCampus extends ConsumerStatefulWidget {
  const IntraCampus({super.key});

  @override
  ConsumerState<IntraCampus> createState() => _IntraCampusState();
}

class _IntraCampusState extends ConsumerState<IntraCampus>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  Map<String, dynamic> _adminPosts = {};
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(intraCampusPostProvider.notifier).fetchPosts();
    });

    ApiClient()
        .get('/api/posts/admin/post?requestUniversity=true')
        .then((value) {
      if (value is Map<String, dynamic>) {
        _adminPosts = value['post'];
        log("_adminPosts in intra $_adminPosts");
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final postState = ref.watch(intraCampusPostProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // final authUser = ref.read(authProvider).user;
    // WebSocketService().joinNotification(authUser!['_id']);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.pixels ==
            notification.metrics.maxScrollExtent) {
          if (!postState.isLoading && postState.hasNextPage) {
            ref.read(intraCampusPostProvider.notifier).fetchPosts();
          }
        }

        if (notification is OverscrollNotification &&
            notification.overscroll < 0) {
          // User is pulling down
          ref.read(intraCampusPostProvider.notifier).fetchPosts(
                refreshIt: true,
              );
        }
        return false;
      },
      child: Column(
        children: [
          if (postState.isRefreshing)
            ShiningLinearProgressBar(
              progress: postState
                  .loadingProgress, // you must add this field, value 0 to 1
              isLoadingComplete: postState.loadingProgress >= 1.0,
            ),
          Expanded(child: _buildPostsList(postState, isDark)),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildPostsList(IntraCampusPostProvider postState, bool isDark) {
    if (postState.isLoading && postState.posts.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40, // reduced from 50
                    margin: const EdgeInsets.all(8.0), // reduced from 12
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  Container(
                    height: 100, // keep as is, no vertical margin
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8.0), // reduced horizontal margin from 12
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  Container(
                    height: 16, // reduced from 20
                    margin: const EdgeInsets.all(8.0), // reduced from 12
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (postState.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Posts',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      ref.read(intraCampusPostProvider.notifier).fetchPosts(
                            refreshIt: true,
                          ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("Refresh",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        )),
                  )),
            ),
            const SizedBox(height: 8),
            Text(
              postState.errorMessage ?? 'Unknown error',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (postState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'No Posts Available',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate total item count
    final hasAdminPost = _adminPosts.isNotEmpty;
    final totalCount = postState.posts.length + (hasAdminPost ? 1 : 0);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (hasAdminPost && index == 0) {
          // First item is the admin post
          return PostCard(
              key: ValueKey(index),
              post: _adminPosts,
              flairType: Flairs.campus.value);
        }

        // Adjust index if admin post is present
        final postIndex = hasAdminPost ? index - 1 : index;
        final post = postState.posts[postIndex];
        // debugPrint('Post at index $index: $post (type: ${post.runtimeType})');

        // Validate post structure
        if (post is! Map<String, dynamic> || post['author']?['_id'] == null) {
          // debugPrint('Invalid post at index $index: $post');
          return const SizedBox.shrink();
        }

        // Fetch user data for author
        // log("VALUE OF FLAIR TYPE ${Flairs.campus.value}");
        return Column(children: [
          PostCard(
            key: ValueKey(index),
            post: post,
            flairType: Flairs.campus.value,
          ),
          // if( index % 10 ==0 )...[const NativeAdPostWidget()]
        ]);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
