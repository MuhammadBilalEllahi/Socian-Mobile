import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/home/widgets/components/post/CreatePost.dart';
import 'package:socian/pages/home/widgets/components/post/page/PostDetailPage.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/constants.dart';

import 'post_media.dart';
import 'post_stat_item.dart';

class PostCard extends ConsumerStatefulWidget {
  final dynamic post;
  final int flairType;

  const PostCard({
    super.key,
    required this.post,
    required this.flairType,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool isLiked = false;

  bool isDisliked = false;
  bool isVoting = false;
  final _apiClient = ApiClient();

  late final authUser;
  late final currentUserId;

  @override
  void initState() {
    super.initState();

    authUser = ref.read(authProvider).user;
    currentUserId = authUser?['_id'];

    final String? yourVoteStatus =
        widget.post['voteId']?['userVotes']?[currentUserId] as String?;
    isLiked = yourVoteStatus == 'upvote';
    isDisliked = yourVoteStatus == 'downvote';
  }

  Future<void> _votePost(String voteType) async {
    if (isVoting) return;

    // Store previous state for rollback in case of error
    final previousUpVotes = widget.post['voteId']['upVotesCount'] as int;
    final previousDownVotes = widget.post['voteId']['downVotesCount'] as int;
    final previousIsLiked = isLiked;
    final previousIsDisliked = isDisliked;

    // Optimistically update UI
    setState(() {
      isVoting = true;

      // Update vote counts and like/dislike state
      if (voteType == 'upvote') {
        if (isLiked) {
          // Undo like
          widget.post['voteId']['upVotesCount']--;
          isLiked = false;
        } else {
          // Apply like
          widget.post['voteId']['upVotesCount']++;
          if (isDisliked) {
            widget.post['voteId']['downVotesCount']--;
            isDisliked = false;
          }
          isLiked = true;
        }
      } else if (voteType == 'downvote') {
        if (isDisliked) {
          // Undo dislike
          widget.post['voteId']['downVotesCount']--;
          isDisliked = false;
        } else {
          // Apply dislike
          widget.post['voteId']['downVotesCount']++;
          if (isLiked) {
            widget.post['voteId']['upVotesCount']--;
            isLiked = false;
          }
          isDisliked = true;
        }
      }
    });

    try {
      final response = await _apiClient.post('/api/posts/vote-post', {
        'postId': widget.post['_id'],
        'voteType': voteType,
      });

      debugPrint('Vote response: $response');

      // Sync with server response
      setState(() {
        widget.post['voteId']['upVotesCount'] = response['upVotesCount'];
        widget.post['voteId']['downVotesCount'] = response['downVotesCount'];

        if (response['noneSelected'] == true) {
          isLiked = false;
          isDisliked = false;
        } else {
          isLiked = voteType == 'upvote' && response['noneSelected'] != true;
          isDisliked =
              voteType == 'downvote' && response['noneSelected'] != true;
        }
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(response['message'])),
      // );
    } catch (e) {
      debugPrint('Error voting: $e');
      // Revert optimistic updates on error
      setState(() {
        widget.post['voteId']['upVotesCount'] = previousUpVotes;
        widget.post['voteId']['downVotesCount'] = previousDownVotes;
        isLiked = previousIsLiked;
        isDisliked = previousIsDisliked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: $e')),
      );
    } finally {
      setState(() {
        isVoting = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      final response =
          await _apiClient.delete('/api/posts/delete', queryParameters: {
        'postId': postId,
      });
      debugPrint('Delete post response: $response');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );

        // Pop back to the previous screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete post. Please try again later.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(String postId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deletePost(postId);
    }
  }

//original post code
  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      // decoration: BoxDecoration(
      //   color: isDark ? const Color.fromARGB(0, 0, 0, 0) : Colors.white,
      //   border:
      //   const Border(
      //     bottom: BorderSide(
      //       color: Colors.grey, // Change color as needed
      //       width: 0.5, // Change thickness as needed
      //     ),
      //   ),
      // ),

      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
        // borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.2),
            // blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 7.5,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                    post: widget.post,
                    flairType: widget.flairType,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(isDark, formattedDate),
                const SizedBox(height: 4),
                _buildPostContent(isDark),
              ],
            ),
          ),
          PostMedia(
            media: media,
            post: widget.post,
            flairType: widget.flairType,
          ),
          const SizedBox(height: 4),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserInfo(bool isDark, String formattedDate) {
    final isSocietyPost = widget.post['society'] != null &&
        widget.post['society']['name'] != null;
    final societyName = isSocietyPost ? widget.post['society']['name'] : '';
    final author = widget.post['author'] ?? {};

    final departmentName = widget.flairType == Flairs.university.value
        ? (widget.post['author']['university']?['universityId']?['name']
                ?.toString() ??
            '')
        : (widget.post['author']?['university']?['departmentId']?['name']
                ?.toString() ??
            '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap:
                author['_id'] != null && author['username']?.isNotEmpty == true
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(userId: author['_id']),
                          ),
                        );
                      }
                    : null,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                backgroundImage: author['profile'] != null
                    ? NetworkImage(author['profile']['picture'] ?? '')
                    : const AssetImage('assets/default_profile_picture.png')
                        as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First line: Name, department (if applicable), and society
                Row(
                  children: [
                    GestureDetector(
                      onTap: author['_id'] != null &&
                              author['username']?.isNotEmpty == true
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(userId: author['_id']),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        author['name'] ?? '{Deleted}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (!isSocietyPost && departmentName.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        departmentName,
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (isSocietyPost) ...[
                      const SizedBox(width: 8),
                      const Text(
                        "➤ ",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isDark
                              ? const Color(0xFF18181B) // shadcn dark accent
                              : const Color(0xFFFAFAFA), // shadcn light accent
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF27272A) // shadcn dark border
                                : const Color(
                                    0xFFE4E4E7), // shadcn light border
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group,
                              size: 12,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF09090B), // shadcn fg
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                societyName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF09090B), // shadcn fg
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                // Username and Date (no containers)
                Row(
                  children: [
                    GestureDetector(
                      onTap: author['_id'] != null &&
                              author['username']?.isNotEmpty == true
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(userId: author['_id']),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        '@${author['username'] ?? ''}',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF27272A) // shadcn dark accent
                            : const Color(0xFFE4E4E7), // shadcn light accent
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              size: 20,
            ),
            onPressed: () async {
              if (author['_id'] == currentUserId) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.report, color: Colors.orange),
                          title: const Text('Report Post'),
                          onTap: () {
                            Navigator.pop(context);
                            _showReportDialog(widget.post['_id']);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.edit,
                              color: Color.fromARGB(255, 255, 255, 255)),
                          title: const Text('Edit Post'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreatePost(
                                  isEditing: true,
                                  postData: widget.post,
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text('Delete Post'),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(widget.post['_id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.report, color: Colors.orange),
                          title: const Text('Report Post'),
                          onTap: () {
                            Navigator.pop(context);
                            _showReportDialog(widget.post['_id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

///////////////////////////////////////////////
  Widget _buildPostContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post['title'] ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.post['body'] ?? '',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PostStatItem(
          icon: isLiked ? Icons.favorite : Icons.favorite_outline,
          count: widget.post['voteId']?['upVotesCount'] ?? 0,
          onTap: () => _votePost('upvote'),
          isActive: isLiked,
        ),
        PostStatItem(
          icon: isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
          count: widget.post['voteId']?['downVotesCount'] ?? 0,
          onTap: () => _votePost('downvote'),
          isActive: isDisliked,
        ),
        PostStatItem(
          icon: Icons.chat_bubble_outline,
          count: widget.post['commentsCount'] ?? 0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(
                  post: widget.post,
                  flairType: widget.flairType,
                ),
              ),
            );
          },
          isActive: false,
        ),
      ],
    );
  }

  Future<void> _showReportDialog(String postId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Spam'),
              onTap: () => Navigator.pop(context, 'Spam'),
            ),
            ListTile(
              title: const Text('Inappropriate Content'),
              onTap: () => Navigator.pop(context, 'Inappropriate Content'),
            ),
            ListTile(
              title: const Text('Harassment'),
              onTap: () => Navigator.pop(context, 'Harassment'),
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () => Navigator.pop(context, 'Other'),
            ),
          ],
        ),
      ),
    );

    if (reason != null) {
      try {
        final response = await _apiClient.post('/api/posts/report', {
          'postId': postId,
          'reason': reason,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post reported successfully')),
          );
        }
      } catch (e) {
        debugPrint('Error reporting post: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to report post')),
          );
        }
      }
    }
  }
}
