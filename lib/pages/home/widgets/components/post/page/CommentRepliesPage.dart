

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/home/widgets/components/post/CreatePost.dart';
import 'package:socian/pages/home/widgets/components/post/page/PostDetailsPage.dart' hide PostMedia, PostStatItem;
import 'package:socian/pages/home/widgets/components/post/post_stat_item.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:timeago/timeago.dart' as timeago;


class CommentRepliesPage extends ConsumerStatefulWidget {
  final String postId;
  final String commentId;
  final String commentAuthor;

  const CommentRepliesPage({
    super.key,
    required this.postId,
    required this.commentId,
    required this.commentAuthor,
  });

  @override
  ConsumerState<CommentRepliesPage> createState() => _CommentRepliesPageState();
}

class _CommentRepliesPageState extends ConsumerState<CommentRepliesPage> {
  final _apiClient = ApiClient();
  final _replyController = TextEditingController();
  bool _isPostingReply = false;
  final Map<String, bool> _isReplyLiked = {};
  final Map<String, bool> _isReplyDisliked = {};
  final Map<String, bool> _isReplyVoting = {};
  List<dynamic> _replies = [];
  late Future<List<dynamic>> _repliesFuture;
  late final authUser;
  late final currentUserId;

  @override
  void initState() {
    super.initState();
    _repliesFuture = _fetchReplies(widget.commentId);
    authUser = ref.read(authProvider).user;
    currentUserId = authUser?['_id'];
  }

  Future<List<dynamic>> _fetchReplies(String commentId) async {
    try {
      final response = await _apiClient
          .getList('/api/posts/post/comment/replies', queryParameters: {
        'commentId': commentId,
      });
      debugPrint('Replies response: $response');
      final replies =
          response.where((r) => !(r['isDeleted'] ?? false)).toList() ?? [];
      setState(() {
        _replies = replies;
      });
      return replies;
    } catch (e) {
      debugPrint('Error fetching replies: $e');
      throw Exception('Failed to load replies: $e');
    }
  }

  Future<void> _refreshReplies() async {
    setState(() {
      _repliesFuture = _fetchReplies(widget.commentId);
    });
  }

  Future<void> _postReply(
      String postId, String commentId, String comment) async {
    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply cannot be empty')),
      );
      return;
    }

    setState(() {
      _isPostingReply = true;
    });

    try {
      final response = await _apiClient.post('/api/posts/post/reply/comment', {
        'postId': postId,
        'commentId': commentId,
        'comment': comment,
      });
      debugPrint('Post reply response: $response');
      _replyController.clear();
      await _refreshReplies();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply posted successfully')),
      );
    } catch (e) {
      debugPrint('Error posting reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post reply: $e')),
      );
    } finally {
      setState(() {
        _isPostingReply = false;
      });
    }
  }

  // Future<void> _voteReply(String replyId, String voteType) async {
  //   if (_isReplyVoting[replyId] == true) return;

  //   setState(() {
  //     _isReplyVoting[replyId] = true;
  //   });

  //   try {
  //     final response = await _apiClient.post('/api/posts/post/comment/vote', {
  //       'commentId': replyId,
  //       'voteType': voteType,
  //     });

  //     debugPrint('Reply vote response: $response');

  //     setState(() {
  //       final replyIndex = _replies.indexWhere((r) => r['_id'] == replyId);
  //       if (replyIndex != -1) {
  //         _replies[replyIndex]['voteId']['upVotesCount'] =
  //             response['upVotesCount'];
  //         _replies[replyIndex]['voteId']['downVotesCount'] =
  //             response['downVotesCount'];
  //       }
  //       _isReplyLiked[replyId] =
  //           voteType == 'upvote' && response['noneSelected'] != true;
  //       _isReplyDisliked[replyId] =
  //           voteType == 'downvote' && response['noneSelected'] != true;
  //       if (response['noneSelected'] == true) {
  //         _isReplyLiked[replyId] = false;
  //         _isReplyDisliked[replyId] = false;
  //       }
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(response['message'])),
  //     );
  //   } catch (e) {
  //     debugPrint('Error voting reply: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to vote reply: $e')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isReplyVoting[replyId] = false;
  //     });
  //   }
  // }

  Future<void> _voteReply(String replyId, String voteType) async {
    if (_isReplyVoting[replyId] == true) return;

    // Store previous state for rollback in case of error
    final replyIndex = _replies.indexWhere((r) => r['_id'] == replyId);
    int previousUpVotes = 0;
    int previousDownVotes = 0;
    bool previousIsLiked = false;
    bool previousIsDisliked = false;

    if (replyIndex != -1) {
      previousUpVotes = _replies[replyIndex]['voteId']['upVotesCount'] as int;
      previousDownVotes =
          _replies[replyIndex]['voteId']['downVotesCount'] as int;
      previousIsLiked = _isReplyLiked[replyId] ?? false;
      previousIsDisliked = _isReplyDisliked[replyId] ?? false;
    }

    // Optimistically update UI
    setState(() {
      _isReplyVoting[replyId] = true;

      if (replyIndex != -1) {
        if (voteType == 'upvote') {
          if (_isReplyLiked[replyId] == true) {
            // Undo like
            _replies[replyIndex]['voteId']['upVotesCount']--;
            _isReplyLiked[replyId] = false;
          } else {
            // Apply like
            _replies[replyIndex]['voteId']['upVotesCount']++;
            if (_isReplyDisliked[replyId] == true) {
              _replies[replyIndex]['voteId']['downVotesCount']--;
              _isReplyDisliked[replyId] = false;
            }
            _isReplyLiked[replyId] = true;
          }
        } else if (voteType == 'downvote') {
          if (_isReplyDisliked[replyId] == true) {
            // Undo dislike
            _replies[replyIndex]['voteId']['downVotesCount']--;
            _isReplyDisliked[replyId] = false;
          } else {
            // Apply dislike
            _replies[replyIndex]['voteId']['downVotesCount']++;
            if (_isReplyLiked[replyId] == true) {
              _replies[replyIndex]['voteId']['upVotesCount']--;
              _isReplyLiked[replyId] = false;
            }
            _isReplyDisliked[replyId] = true;
          }
        }
      } else {
        debugPrint('Reply with ID $replyId not found in _replies');
      }
    });

    try {
      final response = await _apiClient.post('/api/posts/post/comment/vote', {
        'commentId': replyId,
        'voteType': voteType,
      });

      debugPrint('Reply vote response: $response');

      // Sync with server response
      setState(() {
        final replyIndex = _replies.indexWhere((r) => r['_id'] == replyId);
        if (replyIndex != -1) {
          _replies[replyIndex]['voteId']['upVotesCount'] =
              response['upVotesCount'];
          _replies[replyIndex]['voteId']['downVotesCount'] =
              response['downVotesCount'];

          if (response['noneSelected'] == true) {
            _isReplyLiked[replyId] = false;
            _isReplyDisliked[replyId] = false;
          } else {
            _isReplyLiked[replyId] =
                voteType == 'upvote' && response['noneSelected'] != true;
            _isReplyDisliked[replyId] =
                voteType == 'downvote' && response['noneSelected'] != true;
          }
        } else {
          debugPrint('Reply with ID $replyId not found in _replies');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    } catch (e) {
      debugPrint('Error voting reply: $e');
      // Revert optimistic updates on error
      setState(() {
        if (replyIndex != -1) {
          _replies[replyIndex]['voteId']['upVotesCount'] = previousUpVotes;
          _replies[replyIndex]['voteId']['downVotesCount'] = previousDownVotes;
          _isReplyLiked[replyId] = previousIsLiked;
          _isReplyDisliked[replyId] = previousIsDisliked;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote reply: $e')),
      );
    } finally {
      setState(() {
        _isReplyVoting[replyId] = false;
      });
    }
  }

  Future<void> _deleteReply(String replyId) async {
    try {
      final response = await _apiClient
          .delete('/api/posts/post/reply/comment', queryParameters: {
        'replyId': replyId,
      });
      debugPrint('Delete reply response: $response');
      setState(() {
        _replies.removeWhere((r) => r['_id'] == replyId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply deleted successfully')),
      );
    } catch (e) {
      debugPrint('Error deleting reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete reply: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(String replyId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text(
            'Are you sure you want to delete this reply? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteReply(replyId);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDark ? Colors.white : const Color(0xFF09090B);
    final muted = isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent = isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Replies to ${widget.commentAuthor}',
          style: TextStyle(color: foreground),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: foreground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replies',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: foreground),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      hintStyle: TextStyle(color: mutedForeground),
                      filled: true,
                      fillColor: accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: foreground),
                      ),
                    ),
                    style: TextStyle(color: foreground),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isPostingReply
                      ? null
                      : () => _postReply(widget.postId, widget.commentId,
                          _replyController.text),
                  style: TextButton.styleFrom(
                    backgroundColor: foreground,
                    foregroundColor: background,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isPostingReply
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Post',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _repliesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Failed to load replies',
                          style: TextStyle(color: mutedForeground)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No replies yet',
                          style: TextStyle(color: mutedForeground)));
                }

                final replies = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: replies.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: border, height: 24),
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    final author = reply['author'] ?? {};
                    final voteId = reply['voteId'] ?? {};
                    final replyId = reply['_id'];
                    final createdAt =
                        DateTime.tryParse(reply['createdAt'] ?? '') ??
                            DateTime.now();
                    final timeAgo =
                        timeago.format(createdAt, locale: 'en_short');

                    _isReplyLiked[replyId] ??= false;
                    _isReplyDisliked[replyId] ??= false;
                    _isReplyVoting[replyId] ??= false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: author['_id'] != null
                                    ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                                userId: author['_id']),
                                          ),
                                        )
                                    : null,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: author['profile'] != null
                                      ? NetworkImage(
                                          author['profile']['picture'] ?? '')
                                      : const AssetImage(
                                              'assets/default_profile_picture.png')
                                          as ImageProvider,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: author['_id'] != null
                                          ? () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePage(
                                                          userId:
                                                              author['_id']),
                                                ),
                                              )
                                          : null,
                                      child: Text(
                                        author['name'] ?? '{Deleted}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: foreground,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '@${author['username'] ?? ''} • $timeAgo',
                                      style: TextStyle(
                                          color: mutedForeground, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.more_horiz,
                                    color: mutedForeground, size: 20),
                                onPressed: () async {
                                  if (author['_id'] == currentUserId) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              title: const Text('Delete Reply'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _showDeleteConfirmation(
                                                    replyId);
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
                          const SizedBox(height: 8),
                          Text(
                            reply['comment'] ?? '',
                            style: TextStyle(
                                fontSize: 14, color: foreground, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              PostStatItem(
                                icon: _isReplyLiked[replyId]!
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                count: voteId['upVotesCount'] ?? 0,
                                onTap: () => _voteReply(replyId, 'upvote'),
                                isActive: _isReplyLiked[replyId]!,
                              ),
                              const SizedBox(width: 16),
                              PostStatItem(
                                icon: _isReplyDisliked[replyId]!
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_outlined,
                                count: voteId['downVotesCount'] ?? 0,
                                onTap: () => _voteReply(replyId, 'downvote'),
                                isActive: _isReplyDisliked[replyId]!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
