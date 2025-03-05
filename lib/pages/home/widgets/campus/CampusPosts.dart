import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import '../../../../components/PostCard.dart';
import '../../../drawer/MyDrawer.dart';
import 'package:beyondtheclass/core/usecases/PostProvider.dart';
import 'package:shimmer/shimmer.dart';

class CampusPosts extends ConsumerStatefulWidget {
  const CampusPosts({super.key});

  @override
  ConsumerState<CampusPosts> createState() => _CampusPostsState();
}

class _CampusPostsState extends ConsumerState<CampusPosts> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(postProvider.notifier).fetchPosts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postProvider);

    Color postsBgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    Color postsTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    Color titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    Color topIconsColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      drawer: const MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.black,
              toolbarHeight: 70.0,
              centerTitle: false,
              title: Text(
                AppConstants.appName,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              automaticallyImplyLeading: false,
              pinned: true,
              leading: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Icon(Icons.menu_outlined, color: topIconsColor),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: titleColor,
                unselectedLabelColor: titleColor.withOpacity(0.5),
                indicatorColor: titleColor,
                tabs: const [
                  Tab(text: 'Campus'),
                  Tab(text: 'Universities'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // For You Tab
            RefreshIndicator(
              onRefresh: () async {
                await ref.read(postProvider.notifier).fetchPosts();
              },
              child: _buildPostsList(postState, postsBgColor, postsTextColor),
            ),
            // Following Tab
            const Center(
              child: Text('Coming Soon'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(PostProvider postState, Color postsBgColor, Color postsTextColor) {
    if (postState.isLoading) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5, // Show 5 shimmer items while loading
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  Container(
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  Container(
                    height: 20,
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error Loading Posts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              postState.errorMessage ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodySmall,
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
            const Icon(Icons.list, color: Colors.grey, size: 60),
            const SizedBox(height: 16),
            Text(
              'No Posts Available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: postState.posts.length,
      itemBuilder: (context, index) {
        final post = postState.posts[index];
        return PostCard(
          post: post,
          postsBgColor: postsBgColor,
          postsTextColor: postsTextColor,
        );
      },
    );
  }
}