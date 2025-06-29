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
        widget.post['voteId']['userVotes']?[currentUserId] as String?;
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
          PostMedia(media: media),
          const SizedBox(height: 4),
          _buildActionButtons(),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////////
  ///Deepseek's version

// Widget _buildUserInfo(bool isDark, String formattedDate) {
//   final isSocietyPost = widget.post['society'] != null &&
//       widget.post['society']['name'] != null;
//   final societyName = isSocietyPost ? widget.post['society']['name'] : '';
//   final author = widget.post['author'] ?? {};

//   // Get university/department information
//   final institutionInfo = widget.flairType == Flairs.university.value
//       ? (widget.post['author']['university']?['universityId']?['name']?.toString() ?? '')
//       : (widget.post['author']?['university']?['departmentId']?['name']?.toString() ?? '');

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Avatar with society badge
//         Stack(
//           children: [
//             GestureDetector(
//               onTap: author['_id'] != null && author['username']?.isNotEmpty == true
//                   ? () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ProfilePage(userId: author['_id']),
//                         ),
//                       );
//                     }
//                   : null,
//               child: CircleAvatar(
//                 radius: 22,
//                 backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
//                 backgroundImage: author['profile'] != null
//                     ? NetworkImage(author['profile']['picture'] ?? '')
//                     : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
//               ),
//             ),
//             if (isSocietyPost)
//               Positioned(
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.blue,
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: isDark ? Colors.grey[900]! : Colors.white,
//                       width: 2,
//                     ),
//                   ),
//                   child: const Icon(Icons.group, size: 14, color: Colors.white),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Society name (if applicable)
//               if (isSocietyPost)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 2),
//                   child: Text(
//                     societyName,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 13,
//                       color: isDark ? Colors.blue[200] : Colors.blue[700],
//                     ),
//                   ),
//                 ),

//               // Author name and institution in a single line
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: author['_id'] != null &&
//                             author['username']?.isNotEmpty == true
//                         ? () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ProfilePage(userId: author['_id']),
//                               ),
//                             );
//                           }
//                         : null,
//                     child: Text(
//                       author['name'] ?? '{Deleted}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                         color: isDark ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ),
//                   if (institutionInfo.isNotEmpty) ...[
//                     const SizedBox(width: 6),
//                     Text(
//                       '•',
//                       style: TextStyle(
//                         color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Flexible(
//                       child: Text(
//                         institutionInfo,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: isDark ? Colors.grey[400] : Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               const SizedBox(height: 2),

//               // Username and date
//               Row(
//                 children: [
//                   Text(
//                     '@${author['username'] ?? ''}',
//                     style: TextStyle(
//                       color: isDark ? Colors.grey[400] : Colors.grey[600],
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   _buildDotSeparator(isDark),
//                   const SizedBox(width: 8),
//                   DateBadge(date: formattedDate),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         // Options menu button
//         IconButton(
//           icon: Icon(
//             Icons.more_horiz,
//             color: isDark ? Colors.grey[400] : Colors.grey[600],
//             size: 22,
//           ),
//           onPressed: () => _showOptionsMenu(author['_id']),
//         ),
//       ],
//     ),
//   );
// }

// // Helper widget for dot separator
// Widget _buildDotSeparator(bool isDark) {
//   return Container(
//     width: 4,
//     height: 4,
//     decoration: BoxDecoration(
//       color: isDark ? Colors.grey[400] : Colors.grey[600],
//       shape: BoxShape.circle,
//     ),
//   );
// }

// // Options menu handler
// void _showOptionsMenu(String? authorId) {
//   if (authorId == currentUserId) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.edit, color: Colors.blue),
//               title: const Text('Edit Post'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => CreatePost(
//                       isEditing: true,
//                       postData: widget.post,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete, color: Colors.red),
//               title: const Text('Delete Post'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showDeleteConfirmation(widget.post['_id']);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   } else {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.report, color: Colors.orange),
//               title: const Text('Report Post'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showReportDialog(widget.post['_id']);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// claude's version (fixed by grok, further refined by chatgpt)
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




// class PostDetailPage extends ConsumerStatefulWidget {
//   final dynamic post;
//   final int flairType;

//   const PostDetailPage({
//     super.key,
//     required this.post,
//     required this.flairType,
//   });

//   @override
//   ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
// }

// class _PostDetailPageState extends ConsumerState<PostDetailPage> {
//   bool isLiked = false;
//   bool isDisliked = false;
//   bool isVoting = false;
//   final _apiClient = ApiClient();
//   final _commentController = TextEditingController();
//   bool _isPostingComment = false;
//   final Map<String, bool> _isCommentLiked = {};
//   final Map<String, bool> _isCommentDisliked = {};
//   final Map<String, bool> _isCommentVoting = {};
//   List<dynamic> _comments = [];
//   late Future<List<dynamic>> _commentsFuture;
//   late final authUser;
//   late final currentUserId;

//   @override
//   void initState() {
//     super.initState();
//     _commentsFuture = _fetchComments(widget.post['_id']);
//     authUser = ref.read(authProvider).user;
//     currentUserId = authUser?['_id'];
//   }

//   Future<void> _votePost(String voteType) async {
//     if (isVoting) return;

//     setState(() {
//       isVoting = true;
//     });

//     try {
//       final response = await _apiClient.post('/api/posts/vote-post', {
//         'postId': widget.post['_id'],
//         'voteType': voteType,
//       });

//       debugPrint('Vote response: $response');

//       setState(() {
//         widget.post['voteId']['upVotesCount'] = response['upVotesCount'];
//         widget.post['voteId']['downVotesCount'] = response['downVotesCount'];

//         if (response['noneSelected'] == true) {
//           isLiked = false;
//           isDisliked = false;
//         } else {
//           isLiked = voteType == 'upvote' && response['noneSelected'] != true;
//           isDisliked =
//               voteType == 'downvote' && response['noneSelected'] != true;
//         }
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response['message'])),
//       );
//     } catch (e) {
//       debugPrint('Error voting: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to vote: $e')),
//       );
//     } finally {
//       setState(() {
//         isVoting = false;
//       });
//     }
//   }

//   Future<void> _voteComment(String commentId, String voteType) async {
//     if (_isCommentVoting[commentId] == true) return;

//     // Store previous state for rollback in case of error
//     final commentIndex = _comments.indexWhere((c) => c['_id'] == commentId);
//     int previousUpVotes = 0;
//     int previousDownVotes = 0;
//     bool previousIsLiked = false;
//     bool previousIsDisliked = false;

//     if (commentIndex != -1) {
//       previousUpVotes =
//           _comments[commentIndex]['voteId']['upVotesCount'] as int;
//       previousDownVotes =
//           _comments[commentIndex]['voteId']['downVotesCount'] as int;
//       previousIsLiked = _isCommentLiked[commentId] ?? false;
//       previousIsDisliked = _isCommentDisliked[commentId] ?? false;
//     }

//     // Optimistically update UI
//     setState(() {
//       _isCommentVoting[commentId] = true;

//       if (commentIndex != -1) {
//         if (voteType == 'upvote') {
//           if (_isCommentLiked[commentId] == true) {
//             // Undo like
//             _comments[commentIndex]['voteId']['upVotesCount']--;
//             _isCommentLiked[commentId] = false;
//           } else {
//             // Apply like
//             _comments[commentIndex]['voteId']['upVotesCount']++;
//             if (_isCommentDisliked[commentId] == true) {
//               _comments[commentIndex]['voteId']['downVotesCount']--;
//               _isCommentDisliked[commentId] = false;
//             }
//             _isCommentLiked[commentId] = true;
//           }
//         } else if (voteType == 'downvote') {
//           if (_isCommentDisliked[commentId] == true) {
//             // Undo dislike
//             _comments[commentIndex]['voteId']['downVotesCount']--;
//             _isCommentDisliked[commentId] = false;
//           } else {
//             // Apply dislike
//             _comments[commentIndex]['voteId']['downVotesCount']++;
//             if (_isCommentLiked[commentId] == true) {
//               _comments[commentIndex]['voteId']['upVotesCount']--;
//               _isCommentLiked[commentId] = false;
//             }
//             _isCommentDisliked[commentId] = true;
//           }
//         }
//       } else {
//         debugPrint('Comment with ID $commentId not found in _comments');
//       }
//     });

//     try {
//       final response = await _apiClient.post('/api/posts/post/comment/vote', {
//         'commentId': commentId,
//         'voteType': voteType,
//       });

//       debugPrint('Comment vote response: $response');

//       // Sync with server response
//       setState(() {
//         final commentIndex = _comments.indexWhere((c) => c['_id'] == commentId);
//         if (commentIndex != -1) {
//           _comments[commentIndex]['voteId']['upVotesCount'] =
//               response['upVotesCount'];
//           _comments[commentIndex]['voteId']['downVotesCount'] =
//               response['downVotesCount'];

//           if (response['noneSelected'] == true) {
//             _isCommentLiked[commentId] = false;
//             _isCommentDisliked[commentId] = false;
//           } else {
//             _isCommentLiked[commentId] =
//                 voteType == 'upvote' && response['noneSelected'] != true;
//             _isCommentDisliked[commentId] =
//                 voteType == 'downvote' && response['noneSelected'] != true;
//           }
//         } else {
//           debugPrint('Comment with ID $commentId not found in _comments');
//           _refreshComments();
//         }
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response['message'])),
//       );
//     } catch (e) {
//       debugPrint('Error voting comment: $e');
//       // Revert optimistic updates on error
//       setState(() {
//         if (commentIndex != -1) {
//           _comments[commentIndex]['voteId']['upVotesCount'] = previousUpVotes;
//           _comments[commentIndex]['voteId']['downVotesCount'] =
//               previousDownVotes;
//           _isCommentLiked[commentId] = previousIsLiked;
//           _isCommentDisliked[commentId] = previousIsDisliked;
//         }
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to vote comment: $e')),
//       );
//     } finally {
//       setState(() {
//         _isCommentVoting[commentId] = false;
//       });
//     }
//   }

//   Future<void> _deletePost(String postId) async {
//     try {
//       final response =
//           await _apiClient.delete('/api/posts/delete', queryParameters: {
//         'postId': postId,
//       });
//       debugPrint('Delete post response: $response');

//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Post deleted successfully')),
//         );

//         // Pop back to the previous screen
//         if (Navigator.canPop(context)) {
//           Navigator.pop(context);
//         }
//       }
//     } catch (e) {
//       debugPrint('Error deleting post: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to delete post. Please try again later.'),
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _deleteComment(String commentId) async {
//     try {
//       final response =
//           await _apiClient.delete('/api/posts/post/comment', queryParameters: {
//         'commentId': commentId,
//       });
//       debugPrint('Delete comment response: $response');
//       setState(() {
//         _comments.removeWhere((c) => c['_id'] == commentId);
//         widget.post['commentsCount'] = (widget.post['commentsCount'] ?? 1) - 1;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment deleted successfully')),
//       );
//     } catch (e) {
//       debugPrint('Error deleting comment: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete comment: $e')),
//       );
//     }
//   }

//   Future<void> _showDeleteConfirmation(
//       {String? postId, String? commentId}) async {
//     final isPost = postId != null;
//     final id = postId ?? commentId!;
//     final type = isPost ? 'Post' : 'Comment';

//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete $type'),
//         content: Text(
//             'Are you sure you want to delete this $type? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (shouldDelete == true) {
//       if (isPost) {
//         await _deletePost(id);
//       } else {
//         await _deleteComment(id);
//       }
//     }
//   }

//   Future<void> _refreshComments() async {
//     setState(() {
//       _commentsFuture = _fetchComments(widget.post['_id']);
//     });
//   }

//   Future<List<dynamic>> _fetchComments(String postId) async {
//     try {
//       final response = await _apiClient
//           .getList('/api/posts/post/comments', queryParameters: {
//         'postId': postId,
//       });
//       debugPrint('Comments response: $response');
//       if (response.isNotEmpty) {
//         final comments = response[0]['comments']
//                 ?.where((c) => !(c['isDeleted'] ?? false))
//                 .toList() ??
//             [];
//         setState(() {
//           _comments = comments;
//         });
//         return comments;
//       } else if (response is String) {
//         debugPrint('Unexpected string response: $response');
//         throw Exception('Unexpected string response: $response');
//       }
//       return [];
//     } catch (e) {
//       debugPrint('Error fetching comments: $e');
//       throw Exception('Failed to load comments: $e');
//     }
//   }

//   Future<void> _postComment(String postId, String comment) async {
//     if (comment.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment cannot be empty')),
//       );
//       return;
//     }

//     setState(() {
//       _isPostingComment = true;
//     });

//     try {
//       final response = await _apiClient.post('/api/posts/post/comment', {
//         'postId': postId,
//         'comment': comment,
//       });
//       debugPrint('Post comment response: $response');
//       _commentController.clear();
//       setState(() {
//         widget.post['commentsCount'] = (widget.post['commentsCount'] ?? 0) + 1;
//       });
//       await _refreshComments();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment posted successfully')),
//       );
//     } catch (e) {
//       debugPrint('Error posting comment: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to post comment: $e')),
//       );
//     } finally {
//       setState(() {
//         _isPostingComment = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final media = widget.post['media'] as List?;
//     final createdAt = DateTime.parse(widget.post['createdAt']);
//     final formattedDate = DateFormat('MMM d, y').format(createdAt);
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final background = isDark ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDark ? Colors.white : const Color(0xFF09090B);
//     final muted = isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final mutedForeground =
//         isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent = isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: background,
//         elevation: 0,
//         title: Text(
//           'Post Details',
//           style: TextStyle(color: foreground),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: foreground,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 1),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child:
//                     _buildUserInfo(foreground, mutedForeground, formattedDate),
//               ),
//               const SizedBox(height: 4),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: _buildPostContent(foreground),
//               ),
//               if (media != null && media.isNotEmpty) ...[
//                 const SizedBox(height: 4),
//                 PostMedia(media: media),
//               ],
//               const SizedBox(height: 4),
//               _buildActionButtons(foreground, mutedForeground),
//               const SizedBox(height: 4),
//               _buildCommentsSection(
//                   foreground, mutedForeground, border, accent, background),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserInfo(
//       Color foreground, Color mutedForeground, String formattedDate) {
//     final isSocietyPost = widget.post['society'] != null &&
//         widget.post['society']['name'] != null;
//     final societyName = isSocietyPost ? widget.post['society']['name'] : '';
//     final author = widget.post['author'] ?? {};

//     return Row(
//       children: [
//         GestureDetector(
//           onTap: author['_id'] != null && author['username']?.isNotEmpty == true
//               ? () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ProfilePage(userId: author['_id']),
//                     ),
//                   );
//                 }
//               : null,
//           child: CircleAvatar(
//             radius: 18,
//             backgroundImage: author['profile'] != null
//                 ? NetworkImage(author['profile']['picture'] ?? '')
//                 : const AssetImage('assets/default_profile_picture.png')
//                     as ImageProvider,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: author['_id'] != null &&
//                             author['username']?.isNotEmpty == true
//                         ? () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ProfilePage(userId: author['_id']),
//                               ),
//                             );
//                           }
//                         : null,
//                     child: Text(
//                       author['name'] ?? '{Deleted}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                         color: foreground,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     widget.flairType == Flairs.university.value
//                         ? (widget.post['author']['university']?['universityId']
//                                     ?['name']
//                                 ?.toString() ??
//                             '')
//                         : (widget.post['author']?['university']?['departmentId']
//                                     ?['name']
//                                 ?.toString() ??
//                             ''),
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   if (isSocietyPost) ...[
//                     const SizedBox(width: 4),
//                     Icon(
//                       Icons.arrow_right,
//                       size: 16,
//                       color: foreground,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       societyName,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                         color: foreground,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: author['_id'] != null &&
//                             author['username']?.isNotEmpty == true
//                         ? () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ProfilePage(userId: author['_id']),
//                               ),
//                             );
//                           }
//                         : null,
//                     child: Text(
//                       '@${author['username'] ?? ''}',
//                       style: TextStyle(
//                         color: mutedForeground,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Container(
//                     width: 4,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: mutedForeground,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   DateBadge(
//                     date: formattedDate,
//                     fontSize: 10,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         IconButton(
//           icon: Icon(
//             Icons.more_horiz,
//             color: foreground,
//             size: 20,
//           ),
//           onPressed: () async {
//             if (author['_id'] == currentUserId) {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) => SafeArea(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.edit, color: Colors.blue),
//                         title: const Text('Edit Post'),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CreatePost(
//                                 isEditing: true,
//                                 postData: widget.post,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.delete, color: Colors.red),
//                         title: const Text('Delete Post'),
//                         onTap: () {
//                           Navigator.pop(context);
//                           _showDeleteConfirmation(postId: widget.post['_id']);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else {
//               showModalBottomSheet(
//                 context: context,
//                 builder: (context) => SafeArea(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ListTile(
//                         leading: const Icon(Icons.report, color: Colors.orange),
//                         title: const Text('Report Post'),
//                         onTap: () {
//                           Navigator.pop(context);
//                           _showReportDialog(widget.post['_id']);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPostContent(Color foreground) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.post['title'] ?? '',
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w700,
//             color: foreground,
//             height: 1.2,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           widget.post['body'] ?? '',
//           style: TextStyle(
//             fontSize: 12,
//             height: 1.5,
//             color: foreground,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons(Color foreground, Color mutedForeground) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         PostStatItem(
//           icon: isLiked ? Icons.favorite : Icons.favorite_outline,
//           count: widget.post['voteId']?['upVotesCount'] ?? 0,
//           onTap: () => _votePost('upvote'),
//           isActive: isLiked,
//         ),
//         PostStatItem(
//           icon: isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
//           count: widget.post['voteId']?['downVotesCount'] ?? 0,
//           onTap: () => _votePost('downvote'),
//           isActive: isDisliked,
//         ),
//         PostStatItem(
//           icon: Icons.chat_bubble_outline,
//           count: widget.post['commentsCount'] ?? 0,
//           onTap: () {},
//           isActive: false,
//         ),
       
//       ],
//     );
//   }

//   Widget _buildCommentsSection(Color foreground, Color mutedForeground,
//       Color border, Color accent, Color background) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Comments',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: foreground,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _commentController,
//                   decoration: InputDecoration(
//                     hintText: 'Write a comment...',
//                     hintStyle: TextStyle(color: mutedForeground),
//                     filled: true,
//                     fillColor: accent,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(4),
//                       borderSide: BorderSide(color: border),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(4),
//                       borderSide: BorderSide(color: border),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(4),
//                       borderSide: BorderSide(color: foreground),
//                     ),
//                   ),
//                   style: TextStyle(color: foreground),
//                   maxLines: 3,
//                   minLines: 1,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               TextButton(
//                 onPressed: _isPostingComment
//                     ? null
//                     : () => _postComment(
//                         widget.post['_id'], _commentController.text),
//                 style: TextButton.styleFrom(
//                   backgroundColor: foreground,
//                   foregroundColor: background,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: _isPostingComment
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation(Colors.white),
//                         ),
//                       )
//                     : const Text(
//                         'Post',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           FutureBuilder<List<dynamic>>(
//             future: _commentsFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(
//                   child: Text(
//                     'Failed to load comments',
//                     style: TextStyle(color: mutedForeground),
//                   ),
//                 );
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return Center(
//                   child: Text(
//                     'No comments yet',
//                     style: TextStyle(color: mutedForeground),
//                   ),
//                 );
//               }

//               final comments = snapshot.data!;
//               return ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: comments.length,
//                 separatorBuilder: (context, index) => Divider(
//                   color: border,
//                   height: 4,
//                 ),
//                 itemBuilder: (context, index) {
//                   final comment = comments[index];
//                   final author = comment['author'] ?? {};
//                   final voteId = comment['voteId'] ?? {};
//                   final commentId = comment['_id'];
//                   final createdAt = DateTime.parse(comment['createdAt']);
//                   final timeAgo = timeago.format(createdAt, locale: 'en_short');
//                   final replyCount = (comment['replies'] as List?)?.length ?? 0;

//                   _isCommentLiked[commentId] ??= false;
//                   _isCommentDisliked[commentId] ??= false;
//                   _isCommentVoting[commentId] ??= false;
//                   final isDark =
//                       Theme.of(context).brightness == Brightness.dark;
//                   return Container(
//                     // color: isDark
//                     //     ? Colors.black12
//                     //     : const Color.fromARGB(176, 255, 255, 255),
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           color: border,
//                         ),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: author['_id'] != null &&
//                                       author['username']?.isNotEmpty == true
//                                   ? () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => ProfilePage(
//                                               userId: author['_id']),
//                                         ),
//                                       );
//                                     }
//                                   : null,
//                               child: CircleAvatar(
//                                 radius: 12,
//                                 backgroundImage: author['profile'] != null
//                                     ? NetworkImage(
//                                         author['profile']['picture'] ?? '')
//                                     : const AssetImage(
//                                             'assets/default_profile_picture.png')
//                                         as ImageProvider,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   GestureDetector(
//                                     onTap: author['_id'] != null &&
//                                             author['username']?.isNotEmpty ==
//                                                 true
//                                         ? () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     ProfilePage(
//                                                         userId: author['_id']),
//                                               ),
//                                             );
//                                           }
//                                         : null,
//                                     child: Text(
//                                       author['name'] ?? '{Deleted}',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 12,
//                                         color: foreground,
//                                       ),
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: author['_id'] != null &&
//                                             author['username']?.isNotEmpty ==
//                                                 true
//                                         ? () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     ProfilePage(
//                                                         userId: author['_id']),
//                                               ),
//                                             );
//                                           }
//                                         : null,
//                                     child: Text(
//                                       '@${author['username'] ?? ''} • $timeAgo',
//                                       style: TextStyle(
//                                         color: mutedForeground,
//                                         fontSize: 10,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(
//                                 Icons.more_horiz,
//                                 color: mutedForeground,
//                                 size: 20,
//                               ),
//                               onPressed: () async {
//                                 if (author['_id'] == currentUserId) {
//                                   showModalBottomSheet(
//                                     context: context,
//                                     builder: (context) => SafeArea(
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           ListTile(
//                                             leading: const Icon(Icons.delete,
//                                                 color: Colors.red),
//                                             title: const Text('Delete Comment'),
//                                             onTap: () {
//                                               Navigator.pop(context);
//                                               _showDeleteConfirmation(
//                                                   commentId: commentId);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 2),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 26),
//                           child: Text(
//                             comment['comment'] ?? '',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: foreground,
//                               height: 1.4,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 26),
//                           child: Row(
//                             children: [
//                               PostStatItem(
//                                 icon: _isCommentLiked[commentId]!
//                                     ? Icons.favorite
//                                     : Icons.favorite_outline,
//                                 count: voteId['upVotesCount'] ?? 0,
//                                 onTap: () => _voteComment(commentId, 'upvote'),
//                                 isActive: _isCommentLiked[commentId]!,
//                               ),
//                               const SizedBox(width: 8),
//                               PostStatItem(
//                                 icon: _isCommentDisliked[commentId]!
//                                     ? Icons.thumb_down
//                                     : Icons.thumb_down_outlined,
//                                 count: voteId['downVotesCount'] ?? 0,
//                                 onTap: () =>
//                                     _voteComment(commentId, 'downvote'),
//                                 isActive: _isCommentDisliked[commentId]!,
//                               ),
//                               const SizedBox(width: 8),
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => CommentRepliesPage(
//                                         postId: widget.post['_id'],
//                                         commentId: commentId,
//                                         commentAuthor:
//                                             author['name'] ?? '{Deleted}',
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: Text(
//                                   replyCount == 0
//                                       ? 'Reply'
//                                       : '$replyCount repl${replyCount == 1 ? 'y' : 'ies'}',
//                                   style: TextStyle(
//                                     color: mutedForeground,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showReportDialog(String postId) async {
//     final reason = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Report Post'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               title: const Text('Spam'),
//               onTap: () => Navigator.pop(context, 'Spam'),
//             ),
//             ListTile(
//               title: const Text('Inappropriate Content'),
//               onTap: () => Navigator.pop(context, 'Inappropriate Content'),
//             ),
//             ListTile(
//               title: const Text('Harassment'),
//               onTap: () => Navigator.pop(context, 'Harassment'),
//             ),
//             ListTile(
//               title: const Text('Other'),
//               onTap: () => Navigator.pop(context, 'Other'),
//             ),
//           ],
//         ),
//       ),
//     );

//     if (reason != null) {
//       try {
//         final response = await _apiClient.post('/api/posts/report', {
//           'postId': postId,
//           'reason': reason,
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Post reported successfully')),
//           );
//         }
//       } catch (e) {
//         debugPrint('Error reporting post: $e');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to report post')),
//           );
//         }
//       }
//     }
//   }
// }





























// class CommentRepliesPage extends ConsumerStatefulWidget {
//   final String postId;
//   final String commentId;
//   final String commentAuthor;

//   const CommentRepliesPage({
//     super.key,
//     required this.postId,
//     required this.commentId,
//     required this.commentAuthor,
//   });

//   @override
//   ConsumerState<CommentRepliesPage> createState() => _CommentRepliesPageState();
// }

// class _CommentRepliesPageState extends ConsumerState<CommentRepliesPage> {
//   final _apiClient = ApiClient();
//   final _replyController = TextEditingController();
//   bool _isPostingReply = false;
//   final Map<String, bool> _isReplyLiked = {};
//   final Map<String, bool> _isReplyDisliked = {};
//   final Map<String, bool> _isReplyVoting = {};
//   List<dynamic> _replies = [];
//   late Future<List<dynamic>> _repliesFuture;
//   late final authUser;
//   late final currentUserId;

//   @override
//   void initState() {
//     super.initState();
//     _repliesFuture = _fetchReplies(widget.commentId);
//     authUser = ref.read(authProvider).user;
//     currentUserId = authUser?['_id'];
//   }

//   Future<List<dynamic>> _fetchReplies(String commentId) async {
//     try {
//       final response = await _apiClient
//           .getList('/api/posts/post/comment/replies', queryParameters: {
//         'commentId': commentId,
//       });
//       debugPrint('Replies response: $response');
//       final replies =
//           response.where((r) => !(r['isDeleted'] ?? false)).toList() ?? [];
//       setState(() {
//         _replies = replies;
//       });
//       return replies;
//     } catch (e) {
//       debugPrint('Error fetching replies: $e');
//       throw Exception('Failed to load replies: $e');
//     }
//   }

//   Future<void> _refreshReplies() async {
//     setState(() {
//       _repliesFuture = _fetchReplies(widget.commentId);
//     });
//   }

//   Future<void> _postReply(
//       String postId, String commentId, String comment) async {
//     if (comment.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Reply cannot be empty')),
//       );
//       return;
//     }

//     setState(() {
//       _isPostingReply = true;
//     });

//     try {
//       final response = await _apiClient.post('/api/posts/post/reply/comment', {
//         'postId': postId,
//         'commentId': commentId,
//         'comment': comment,
//       });
//       debugPrint('Post reply response: $response');
//       _replyController.clear();
//       await _refreshReplies();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Reply posted successfully')),
//       );
//     } catch (e) {
//       debugPrint('Error posting reply: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to post reply: $e')),
//       );
//     } finally {
//       setState(() {
//         _isPostingReply = false;
//       });
//     }
//   }

//   // Future<void> _voteReply(String replyId, String voteType) async {
//   //   if (_isReplyVoting[replyId] == true) return;

//   //   setState(() {
//   //     _isReplyVoting[replyId] = true;
//   //   });

//   //   try {
//   //     final response = await _apiClient.post('/api/posts/post/comment/vote', {
//   //       'commentId': replyId,
//   //       'voteType': voteType,
//   //     });

//   //     debugPrint('Reply vote response: $response');

//   //     setState(() {
//   //       final replyIndex = _replies.indexWhere((r) => r['_id'] == replyId);
//   //       if (replyIndex != -1) {
//   //         _replies[replyIndex]['voteId']['upVotesCount'] =
//   //             response['upVotesCount'];
//   //         _replies[replyIndex]['voteId']['downVotesCount'] =
//   //             response['downVotesCount'];
//   //       }
//   //       _isReplyLiked[replyId] =
//   //           voteType == 'upvote' && response['noneSelected'] != true;
//   //       _isReplyDisliked[replyId] =
//   //           voteType == 'downvote' && response['noneSelected'] != true;
//   //       if (response['noneSelected'] == true) {
//   //         _isReplyLiked[replyId] = false;
//   //         _isReplyDisliked[replyId] = false;
//   //       }
//   //     });

//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text(response['message'])),
//   //     );
//   //   } catch (e) {
//   //     debugPrint('Error voting reply: $e');
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Failed to vote reply: $e')),
//   //     );
//   //   } finally {
//   //     setState(() {
//   //       _isReplyVoting[replyId] = false;
//   //     });
//   //   }
//   // }

//   Future<void> _voteReply(String replyId, String voteType) async {
//     if (_isReplyVoting[replyId] == true) return;

//     // Store previous state for rollback in case of error
//     final replyIndex = _replies.indexWhere((r) => r['_id'] == replyId);
//     int previousUpVotes = 0;
//     int previousDownVotes = 0;
//     bool previousIsLiked = false;
//     bool previousIsDisliked = false;

//     if (replyIndex != -1) {
//       previousUpVotes = _replies[replyIndex]['voteId']['upVotesCount'] as int;
//       previousDownVotes =
//           _replies[replyIndex]['voteId']['downVotesCount'] as int;
//       previousIsLiked = _isReplyLiked[replyId] ?? false;
//       previousIsDisliked = _isReplyDisliked[replyId] ?? false;
//     }

//     // Optimistically update UI
//     setState(() {
//       _isReplyVoting[replyId] = true;

//       if (replyIndex != -1) {
//         if (voteType == 'upvote') {
//           if (_isReplyLiked[replyId] == true) {
//             // Undo like
//             _replies[replyIndex]['voteId']['upVotesCount']--;
//             _isReplyLiked[replyId] = false;
//           } else {
//             // Apply like
//             _replies[replyIndex]['voteId']['upVotesCount']++;
//             if (_isReplyDisliked[replyId] == true) {
//               _replies[replyIndex]['voteId']['downVotesCount']--;
//               _isReplyDisliked[replyId] = false;
//             }
//             _isReplyLiked[replyId] = true;
//           }
//         } else if (voteType == 'downvote') {
//           if (_isReplyDisliked[replyId] == true) {
//             // Undo dislike
//             _replies[replyIndex]['voteId']['downVotesCount']--;
//             _isReplyDisliked[replyId] = false;
//           } else {
//             // Apply dislike
//             _replies[replyIndex]['voteId']['downVotesCount']++;
//             if (_isReplyLiked[replyId] == true) {
//               _replies[replyIndex]['voteId']['upVotesCount']--;
//               _isReplyLiked[replyId] = false;
//             }
//             _isReplyDisliked[replyId] = true;
//           }
//         }
//       } else {
//         debugPrint('Reply with ID $replyId not found in _replies');
//       }
//     });

//     try {
//       final response = await _apiClient.post('/api/posts/post/comment/vote', {
//         'commentId': replyId,
//         'voteType': voteType,
//       });

//       debugPrint('Reply vote response: $response');

//       // Sync with server response
//       setState(() {
//         final replyIndex = _replies.indexWhere((r) => r['_id'] == replyId);
//         if (replyIndex != -1) {
//           _replies[replyIndex]['voteId']['upVotesCount'] =
//               response['upVotesCount'];
//           _replies[replyIndex]['voteId']['downVotesCount'] =
//               response['downVotesCount'];

//           if (response['noneSelected'] == true) {
//             _isReplyLiked[replyId] = false;
//             _isReplyDisliked[replyId] = false;
//           } else {
//             _isReplyLiked[replyId] =
//                 voteType == 'upvote' && response['noneSelected'] != true;
//             _isReplyDisliked[replyId] =
//                 voteType == 'downvote' && response['noneSelected'] != true;
//           }
//         } else {
//           debugPrint('Reply with ID $replyId not found in _replies');
//         }
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response['message'])),
//       );
//     } catch (e) {
//       debugPrint('Error voting reply: $e');
//       // Revert optimistic updates on error
//       setState(() {
//         if (replyIndex != -1) {
//           _replies[replyIndex]['voteId']['upVotesCount'] = previousUpVotes;
//           _replies[replyIndex]['voteId']['downVotesCount'] = previousDownVotes;
//           _isReplyLiked[replyId] = previousIsLiked;
//           _isReplyDisliked[replyId] = previousIsDisliked;
//         }
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to vote reply: $e')),
//       );
//     } finally {
//       setState(() {
//         _isReplyVoting[replyId] = false;
//       });
//     }
//   }

//   Future<void> _deleteReply(String replyId) async {
//     try {
//       final response = await _apiClient
//           .delete('/api/posts/post/reply/comment', queryParameters: {
//         'replyId': replyId,
//       });
//       debugPrint('Delete reply response: $response');
//       setState(() {
//         _replies.removeWhere((r) => r['_id'] == replyId);
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Reply deleted successfully')),
//       );
//     } catch (e) {
//       debugPrint('Error deleting reply: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete reply: $e')),
//       );
//     }
//   }

//   Future<void> _showDeleteConfirmation(String replyId) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Reply'),
//         content: const Text(
//             'Are you sure you want to delete this reply? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (shouldDelete == true) {
//       await _deleteReply(replyId);
//     }
//   }

//   @override
//   void dispose() {
//     _replyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final background = isDark ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDark ? Colors.white : const Color(0xFF09090B);
//     final muted = isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final mutedForeground =
//         isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent = isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: background,
//         elevation: 0,
//         title: Text(
//           'Replies to ${widget.commentAuthor}',
//           style: TextStyle(color: foreground),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: foreground),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Replies',
//               style: TextStyle(
//                   fontSize: 18, fontWeight: FontWeight.w600, color: foreground),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _replyController,
//                     decoration: InputDecoration(
//                       hintText: 'Write a reply...',
//                       hintStyle: TextStyle(color: mutedForeground),
//                       filled: true,
//                       fillColor: accent,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: border),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: border),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: foreground),
//                       ),
//                     ),
//                     style: TextStyle(color: foreground),
//                     maxLines: 3,
//                     minLines: 1,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton(
//                   onPressed: _isPostingReply
//                       ? null
//                       : () => _postReply(widget.postId, widget.commentId,
//                           _replyController.text),
//                   style: TextButton.styleFrom(
//                     backgroundColor: foreground,
//                     foregroundColor: background,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: _isPostingReply
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation(Colors.white),
//                           ),
//                         )
//                       : const Text('Post',
//                           style: TextStyle(fontWeight: FontWeight.w600)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             FutureBuilder<List<dynamic>>(
//               future: _repliesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                       child: Text('Failed to load replies',
//                           style: TextStyle(color: mutedForeground)));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(
//                       child: Text('No replies yet',
//                           style: TextStyle(color: mutedForeground)));
//                 }

//                 final replies = snapshot.data!;
//                 return ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: replies.length,
//                   separatorBuilder: (context, index) =>
//                       Divider(color: border, height: 24),
//                   itemBuilder: (context, index) {
//                     final reply = replies[index];
//                     final author = reply['author'] ?? {};
//                     final voteId = reply['voteId'] ?? {};
//                     final replyId = reply['_id'];
//                     final createdAt =
//                         DateTime.tryParse(reply['createdAt'] ?? '') ??
//                             DateTime.now();
//                     final timeAgo =
//                         timeago.format(createdAt, locale: 'en_short');

//                     _isReplyLiked[replyId] ??= false;
//                     _isReplyDisliked[replyId] ??= false;
//                     _isReplyVoting[replyId] ??= false;

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               GestureDetector(
//                                 onTap: author['_id'] != null
//                                     ? () => Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) => ProfilePage(
//                                                 userId: author['_id']),
//                                           ),
//                                         )
//                                     : null,
//                                 child: CircleAvatar(
//                                   radius: 16,
//                                   backgroundImage: author['profile'] != null
//                                       ? NetworkImage(
//                                           author['profile']['picture'] ?? '')
//                                       : const AssetImage(
//                                               'assets/default_profile_picture.png')
//                                           as ImageProvider,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     GestureDetector(
//                                       onTap: author['_id'] != null
//                                           ? () => Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       ProfilePage(
//                                                           userId:
//                                                               author['_id']),
//                                                 ),
//                                               )
//                                           : null,
//                                       child: Text(
//                                         author['name'] ?? '{Deleted}',
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 14,
//                                           color: foreground,
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       '@${author['username'] ?? ''} • $timeAgo',
//                                       style: TextStyle(
//                                           color: mutedForeground, fontSize: 12),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.more_horiz,
//                                     color: mutedForeground, size: 20),
//                                 onPressed: () async {
//                                   if (author['_id'] == currentUserId) {
//                                     showModalBottomSheet(
//                                       context: context,
//                                       builder: (context) => SafeArea(
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             ListTile(
//                                               leading: const Icon(Icons.delete,
//                                                   color: Colors.red),
//                                               title: const Text('Delete Reply'),
//                                               onTap: () {
//                                                 Navigator.pop(context);
//                                                 _showDeleteConfirmation(
//                                                     replyId);
//                                               },
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             reply['comment'] ?? '',
//                             style: TextStyle(
//                                 fontSize: 14, color: foreground, height: 1.4),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               PostStatItem(
//                                 icon: _isReplyLiked[replyId]!
//                                     ? Icons.favorite
//                                     : Icons.favorite_outline,
//                                 count: voteId['upVotesCount'] ?? 0,
//                                 onTap: () => _voteReply(replyId, 'upvote'),
//                                 isActive: _isReplyLiked[replyId]!,
//                               ),
//                               const SizedBox(width: 16),
//                               PostStatItem(
//                                 icon: _isReplyDisliked[replyId]!
//                                     ? Icons.thumb_down
//                                     : Icons.thumb_down_outlined,
//                                 count: voteId['downVotesCount'] ?? 0,
//                                 onTap: () => _voteReply(replyId, 'downvote'),
//                                 isActive: _isReplyDisliked[replyId]!,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
