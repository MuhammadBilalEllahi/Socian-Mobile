import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'MyDrawer.dart';
import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart'; // For date formatting

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

  Widget _buildStatItem({required String emoji, required int count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBadge(String date,context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, size: 14,
              // color: Colors.white.withOpacity(0.7)
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {

    Color postsBgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white//for dark mode
        : Colors.blueGrey;//for light mode

    Color postsTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    Color titleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    Color topIconsColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    bool isDataFetched = false;
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
              }
              else if (snapshot.hasError) {
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
              }
              else if (snapshot.data?.isEmpty ?? true) {
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
              }
              else {
                final postList = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = postList[index];
                      final createdAt = DateTime.parse(post['createdAt']);
                      final formattedDate = DateFormat('MMM d, y').format(createdAt); // Format the date
                      final upVotesCount = post['voteId']?['upVotesCount'] ?? 0;
                      final downVotesCount = post['voteId']?['downVotesCount'] ?? 0;
                      final commentsCount = post['commentsCount'] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          child:
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                             color: postsBgColor,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.3),
                                        Colors.grey.withOpacity(0.4),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: Offset(3, 3),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: Offset(-3, -3),
                                      ),
                                    ],
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
                                                  : AssetImage('assets/default_profile_picture.png') as ImageProvider,
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  post['author']?['name'] ?? '{Deleted}',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: postsTextColor),
                                                ),
                                                Text(
                                                  '@${post['author']?['username'] ?? ''}',
                                                  style: TextStyle(fontSize: 12, color: postsTextColor),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Icon(Icons.more_vert,color: postsTextColor),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          post['title'] ?? '',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: postsTextColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,

                                        ),
                                        Text(
                                          post['body'] ?? '',
                                          style: TextStyle(fontSize: 13,color: postsTextColor),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _buildStatItem(emoji: '👏🏻', count: upVotesCount),
                                                const SizedBox(width: 8),
                                                _buildStatItem(emoji: '👎🏻', count: downVotesCount),
                                                const SizedBox(width: 8),
                                                _buildStatItem(emoji: '💬', count: commentsCount),
                                              ],
                                            ),
                                            _buildDateBadge(formattedDate,context),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
