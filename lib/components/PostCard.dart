
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class PostCard extends StatelessWidget {
  final dynamic post;
  final Color postsBgColor;
  final Color postsTextColor;

  const PostCard({
    super.key,
    required this.post,
    required this.postsBgColor,
    required this.postsTextColor,
  });

  Widget _buildStatItem({required String emoji, required int count, required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBadge(String date, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, size: 10,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
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

  void _showFullPostDialog(BuildContext context) {
    final createdAt = DateTime.parse(post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final upVotesCount = post['voteId']?['upVotesCount'] ?? 0;
    final downVotesCount = post['voteId']?['downVotesCount'] ?? 0;
    final commentsCount = post['commentsCount'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: postsBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
                      offset: const Offset(3, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(-3, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: post['author'] != null && post['author']['profile'] != null
                                ? NetworkImage(post['author']['profile']['picture'] ?? '')
                                : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['author']?['name'] ?? '{Deleted}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: postsTextColor),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '@${post['author']?['username'] ?? ''}',
                                    style: TextStyle(fontSize: 12, color: postsTextColor),
                                  ),
                                  const SizedBox(width: 5,),
                                  Icon(Icons.circle, size: 5, color: postsTextColor),
                                  const SizedBox(width: 5,),
                                  _buildDateBadge(formattedDate, context),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close, color: postsTextColor),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post['title'] ?? '',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: postsTextColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post['body'] ?? '',
                        style: TextStyle(fontSize: 14, color: postsTextColor),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildStatItem(emoji: '👏🏻', count: upVotesCount, context: context),
                              const SizedBox(width: 8),
                              _buildStatItem(emoji: '👎🏻', count: downVotesCount, context: context),
                              const SizedBox(width: 8),
                              _buildStatItem(emoji: '💬', count: commentsCount, context: context),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullPostDialog(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ClipRRect(
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
                        offset: const Offset(3, 3),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(-3, -3),
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
                                  : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['author']?['name'] ?? '{Deleted}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: postsTextColor),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '@${post['author']?['username'] ?? ''}',
                                      style: TextStyle(fontSize: 12, color: postsTextColor),
                                    ),
                                    const SizedBox(width: 5,),
                                    Icon(Icons.circle, size: 5, color: postsTextColor),
                                    const SizedBox(width: 5,),
                                    _buildDateBadge(DateFormat('MMM d, y').format(DateTime.parse(post['createdAt'])), context),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(Icons.more_vert, color: postsTextColor),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post['title'] ?? '',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: postsTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post['body'] ?? '',
                          style: TextStyle(fontSize: 13, color: postsTextColor),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildStatItem(emoji: '👍🏼', count: post['voteId']?['upVotesCount'] ?? 0, context: context),
                                const SizedBox(width: 8),
                                _buildStatItem(emoji: '👎🏻', count: post['voteId']?['downVotesCount'] ?? 0, context: context),
                                const SizedBox(width: 8),
                                _buildStatItem(emoji: '💬', count: post['commentsCount'] ?? 0, context: context),
                              ],
                            ),
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
      ),
    );
  }
}