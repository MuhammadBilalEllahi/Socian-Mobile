
import 'package:beyondtheclass/components/loader.dart';
import 'package:beyondtheclass/pages/home/widgets/campus/components/post/create_post.dart';
import 'package:beyondtheclass/pages/home/widgets/campus/components/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/core/usecases/PostProvider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../drawer/student/StudentDrawer.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      drawer: const StudentDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              centerTitle: true,
              backgroundColor: isDark ? Colors.black : Colors.white,
              elevation: 0,toolbarHeight: 60.0,

              pinned: true,
              floating: true,
              expandedHeight: 120.0,
              automaticallyImplyLeading: false,
              title: Text(
                AppConstants.appName,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Icon(
                    Icons.menu_outlined,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Material(
                    color: isDark ? Colors.black : Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: isDark ? Colors.white : Colors.black,
                      unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
                      indicatorColor: isDark ? Colors.white : Colors.black,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Campus'),
                        Tab(text: 'Universities'),
                      ],
                    ),
                  ),
                ),
              ),
            )


          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: () async => ref.read(postProvider.notifier).fetchPosts(),
              child: _buildPostsList(postState, isDark, size),
            ),
            Center(
              child: Text('Coming Soon', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: size.width * 0.04)),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 56),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatePost(
                  societies: [
                    {'id': '1', 'name': 'Computer Science Society'},
                    {'id': '2', 'name': 'Photography Club'},
                  ],
                ),
              ),
            );
          },
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildPostsList(PostProvider postState, bool isDark, Size size) {
    if (postState.isLoading) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.04),
              height: size.height * 0.25,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          );
        },
      );
    }

    if (postState.hasError) {
      return Center(
        child: Text(
          'Error Loading Posts',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: size.width * 0.04),
        ),
      );
    }

    if (postState.posts.isEmpty) {
      return Center(
        child: Text(
          'No Posts Available',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: size.width * 0.04),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: postState.posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: postState.posts[index]);
      },
    );
  }
}
