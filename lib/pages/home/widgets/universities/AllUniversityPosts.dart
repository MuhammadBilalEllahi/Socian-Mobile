import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socian/components/effects/ShiningLinearProgressBar.dart';
import 'package:socian/pages/home/widgets/components/post/post.dart';
import 'package:socian/pages/home/widgets/universities/universitypostProvider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';

class AllUniversityPosts extends ConsumerStatefulWidget {
  const AllUniversityPosts({super.key});

  @override
  ConsumerState<AllUniversityPosts> createState() => _AllUniversityPostsState();
}

class _AllUniversityPostsState extends ConsumerState<AllUniversityPosts>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  bool _isFetching = false;
  Map<String, dynamic> _adminPosts = {};

  void _onScroll() {
    final provider = ref.read(universitypostProvider.notifier);
    print("onScroll: checking scroll position...");
    if (_scrollController.position.extentAfter < 500 &&
        provider.hasNextPage &&
        !_isFetching &&
        !provider.isLoading) {
      _isFetching = true;
      provider.fetchPosts().whenComplete(() => _isFetching = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      ref.read(universitypostProvider.notifier).fetchPosts();
    });

    Future.microtask(() async {
      try {
        final apiClient = ApiClient();
        final response =
            await apiClient.get('/api/posts/admin/post?allUniversities=true');
        if (response is Map<String, dynamic>) {
          log("All UNIVERSTIES ______________ $response");
          _adminPosts = response;
        }
      } catch (e) {
        debugPrint("Error in All Universities $e");
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final postState = ref.watch(universitypostProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // final authUser = ref.read(authProvider).user;
    // WebSocketService().joinNotification(authUser!['_id']);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is OverscrollNotification &&
            notification.overscroll < 0) {
          // User is pulling down
          ref.read(universitypostProvider.notifier).fetchPosts(
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

  Widget _buildPostsList(UniversityPostProvider postState, bool isDark) {
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
                      ref.read(universitypostProvider.notifier).fetchPosts(
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
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: totalCount,
      // itemExtent: 500,
      // prototypeItem: PostCard(post: postState.posts.first, flairType: Flairs.university.value),

      itemBuilder: (context, index) {
        if (hasAdminPost && index == 0) {
          // First item is the admin post
          return PostCard(
              key: ValueKey(_adminPosts['_id']),
              post: _adminPosts['post'],
              flairType: Flairs.university.value);
        }

        // Adjust index if admin post is present
        final postIndex = hasAdminPost ? index - 1 : index;
        final post = postState.posts[postIndex];
        if (post is! Map<String, dynamic> || post['author']?['_id'] == null) {
          return const SizedBox.shrink();
        }
        return Column(
          key: ValueKey(post['_id']),
          children: [
            PostCard(
              post: post,
              flairType: Flairs.university.value,
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
