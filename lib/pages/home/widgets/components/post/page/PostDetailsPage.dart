import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/pages/home/widgets/components/post/CreatePost.dart';
import 'package:socian/pages/home/widgets/components/post/page/CommentRepliesPage.dart';
import 'package:socian/pages/home/widgets/components/post/post_media.dart';
import 'package:socian/pages/home/widgets/components/post/post_stat_item.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  final int flairType;

  const PostDetailPage({
    super.key,
    required this.post,
    required this.flairType,
  });

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  bool isLiked = false;
  bool isDisliked = false;
  bool isVoting = false;
  final _apiClient = ApiClient();
  final _commentController = TextEditingController();
  bool _isPostingComment = false;
  final Map<String, bool> _isCommentLiked = {};
  final Map<String, bool> _isCommentDisliked = {};
  final Map<String, bool> _isCommentVoting = {};
  List<dynamic> _comments = [];
  late Future<List<dynamic>> _commentsFuture;
  Map<String, dynamic>? authUser;

  @override
  void initState() {
    super.initState();
    final postId = widget.post['_id'] is Map
        ? widget.post['_id']['id']
        : widget.post['_id'];
    _commentsFuture = _fetchComments(postId);
    // authUser = ref.read(authProvider);
    isLiked = widget.post['voteId']?['userVote'] == 'upvote';
    isDisliked = widget.post['voteId']?['userVote'] == 'downvote';
  }

  Future<void> _votePost(String voteType) async {
    if (isVoting) return;

    final previousUpVotes = widget.post['voteId']?['upVotesCount'] ?? 0;
    final previousDownVotes = widget.post['voteId']?['downVotesCount'] ?? 0;
    final previousIsLiked = isLiked;
    final previousIsDisliked = isDisliked;

    setState(() {
      isVoting = true;
      if (voteType == 'upvote') {
        if (isLiked) {
          widget.post['voteId']['upVotesCount']--;
          isLiked = false;
        } else {
          widget.post['voteId']['upVotesCount']++;
          if (isDisliked) {
            widget.post['voteId']['downVotesCount']--;
            isDisliked = false;
          }
          isLiked = true;
        }
      } else if (voteType == 'downvote') {
        if (isDisliked) {
          widget.post['voteId']['downVotesCount']--;
          isDisliked = false;
        } else {
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
      final postId = widget.post['_id'] is Map
          ? widget.post['_id']['id']
          : widget.post['_id'];
      final response = await _apiClient.post('/api/posts/vote-post', {
        'postId': postId,
        'voteType': voteType,
      });

      setState(() {
        widget.post['voteId']['upVotesCount'] = response['upVotesCount'] ?? 0;
        widget.post['voteId']['downVotesCount'] =
            response['downVotesCount'] ?? 0;
        isLiked =
            response['noneSelected'] == true ? false : voteType == 'upvote';
        isDisliked =
            response['noneSelected'] == true ? false : voteType == 'downvote';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Vote updated')),
        );
      }
    } catch (e) {
      setState(() {
        widget.post['voteId']['upVotesCount'] = previousUpVotes;
        widget.post['voteId']['downVotesCount'] = previousDownVotes;
        isLiked = previousIsLiked;
        isDisliked = previousIsDisliked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to vote: $e')),
        );
      }
    } finally {
      setState(() {
        isVoting = false;
      });
    }
  }

  Future<void> _voteComment(String commentId, String voteType) async {
    if (_isCommentVoting[commentId] == true) return;

    final commentIndex = _comments.indexWhere((c) => c['_id'] == commentId);
    int previousUpVotes = 0;
    int previousDownVotes = 0;
    bool previousIsLiked = false;
    bool previousIsDisliked = false;

    if (commentIndex != -1) {
      previousUpVotes = _comments[commentIndex]['voteId']['upVotesCount'] ?? 0;
      previousDownVotes =
          _comments[commentIndex]['voteId']['downVotesCount'] ?? 0;
      previousIsLiked = _isCommentLiked[commentId] ?? false;
      previousIsDisliked = _isCommentDisliked[commentId] ?? false;
    }

    setState(() {
      _isCommentVoting[commentId] = true;
      if (commentIndex != -1) {
        if (voteType == 'upvote') {
          if (_isCommentLiked[commentId] == true) {
            _comments[commentIndex]['voteId']['upVotesCount']--;
            _isCommentLiked[commentId] = false;
          } else {
            _comments[commentIndex]['voteId']['upVotesCount']++;
            if (_isCommentDisliked[commentId] == true) {
              _comments[commentIndex]['voteId']['downVotesCount']--;
              _isCommentDisliked[commentId] = false;
            }
            _isCommentLiked[commentId] = true;
          }
        } else if (voteType == 'downvote') {
          if (_isCommentDisliked[commentId] == true) {
            _comments[commentIndex]['voteId']['downVotesCount']--;
            _isCommentDisliked[commentId] = false;
          } else {
            _comments[commentIndex]['voteId']['downVotesCount']++;
            if (_isCommentLiked[commentId] == true) {
              _comments[commentIndex]['voteId']['upVotesCount']--;
              _isCommentLiked[commentId] = false;
            }
            _isCommentDisliked[commentId] = true;
          }
        }
      }
    });

    try {
      final response = await _apiClient.post('/api/posts/post/comment/vote', {
        'commentId': commentId,
        'voteType': voteType,
      });

      setState(() {
        if (commentIndex != -1) {
          _comments[commentIndex]['voteId']['upVotesCount'] =
              response['upVotesCount'] ?? 0;
          _comments[commentIndex]['voteId']['downVotesCount'] =
              response['downVotesCount'] ?? 0;
          _isCommentLiked[commentId] =
              response['noneSelected'] == true ? false : voteType == 'upvote';
          _isCommentDisliked[commentId] =
              response['noneSelected'] == true ? false : voteType == 'downvote';
        } else {
          _refreshComments();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Comment vote updated')),
        );
      }
    } catch (e) {
      setState(() {
        if (commentIndex != -1) {
          _comments[commentIndex]['voteId']['upVotesCount'] = previousUpVotes;
          _comments[commentIndex]['voteId']['downVotesCount'] =
              previousDownVotes;
          _isCommentLiked[commentId] = previousIsLiked;
          _isCommentDisliked[commentId] = previousIsDisliked;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to vote comment: $e')),
        );
      }
    } finally {
      setState(() {
        _isCommentVoting[commentId] = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      final response =
          await _apiClient.delete('/api/posts/delete', queryParameters: {
        'postId': postId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final commentIndex = _comments.indexWhere((c) => c['_id'] == commentId);
    dynamic removedComment;
    if (commentIndex != -1) {
      setState(() {
        removedComment = _comments.removeAt(commentIndex);
        widget.post['commentsCount'] = (widget.post['commentsCount'] ?? 1) - 1;
      });
    }

    try {
      final response =
          await _apiClient.delete('/api/posts/post/comment', queryParameters: {
        'commentId': commentId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully')),
        );
      }
    } catch (e) {
      if (commentIndex != -1 && removedComment != null) {
        setState(() {
          _comments.insert(commentIndex, removedComment);
          widget.post['commentsCount'] =
              (widget.post['commentsCount'] ?? 0) + 1;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(
      {String? postId, String? commentId}) async {
    final isPost = postId != null;
    final id = postId ?? commentId!;
    final type = isPost ? 'Post' : 'Comment';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type'),
        content: Text(
            'Are you sure you want to delete this $type? This action cannot be undone.'),
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
      if (isPost) {
        await _deletePost(id);
      } else {
        await _deleteComment(id);
      }
    }
  }

  Future<void> _refreshComments() async {
    setState(() {
      final postId = widget.post['_id'] is Map
          ? widget.post['_id']['id']
          : widget.post['_id'];
      _commentsFuture = _fetchComments(postId);
    });
  }

  Future<List<dynamic>> _fetchComments(String postId) async {
    try {
      final response = await _apiClient
          .getList('/api/posts/post/comments', queryParameters: {
        'postId': postId,
      });
      if (response.isNotEmpty) {
        final comments = response[0]['comments']
                ?.where((c) => !(c['isDeleted'] ?? false))
                .toList() ??
            [];
        setState(() {
          _comments = comments;
          for (var comment in comments) {
            final commentId = comment['_id'];
            _isCommentLiked[commentId] ??=
                comment['voteId']?['userVote'] == 'upvote';
            _isCommentDisliked[commentId] ??=
                comment['voteId']?['userVote'] == 'downvote';
            _isCommentVoting[commentId] ??= false;
          }
        });
        return comments;
      }
      return [];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
      return [];
    }
  }

  Future<void> _postComment(String postId, String comment) async {
    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    final tempCommentId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticComment = {
      '_id': tempCommentId,
      'comment': comment,
      'author': authUser,
      'createdAt': DateTime.now().toIso8601String(),
      'voteId': {'upVotesCount': 0, 'downVotesCount': 0},
      'replies': [],
    };
    setState(() {
      _isPostingComment = true;
      _comments.insert(0, optimisticComment);
      widget.post['commentsCount'] = (widget.post['commentsCount'] ?? 0) + 1;
    });

    try {
      final response = await _apiClient.post('/api/posts/post/comment', {
        'postId': postId,
        'comment': comment,
      });
      _commentController.clear();
      await _refreshComments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment posted successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _comments.removeWhere((c) => c['_id'] == tempCommentId);
        widget.post['commentsCount'] = (widget.post['commentsCount'] ?? 1) - 1;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      setState(() {
        _isPostingComment = false;
      });
    }
  }

  Future<void> _showReportDialog(String id) async {
    final isComment = widget.post['_id'] != id;
    final type = isComment ? 'Comment' : 'Post';
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report $type'),
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
          isComment ? 'commentId' : 'postId': id,
          'reason': reason,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$type reported successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to report $type: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List<dynamic>?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
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
          'Post',
          style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: foreground),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: foreground, size: 22),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildUserInfo(foreground, mutedForeground, formattedDate),
                    const SizedBox(height: 12),
                    _buildPostContent(foreground),
                    if (media != null && media.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      PostMedia(media: media),
                    ],
                    const SizedBox(height: 12),
                    _buildActionButtons(foreground, mutedForeground, border),
                    const SizedBox(height: 16),
                    _buildCommentsSection(foreground, mutedForeground, border,
                        accent, background),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          _buildCommentInput(
              foreground, mutedForeground, border, accent, background),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
      Color foreground, Color mutedForeground, String formattedDate) {
    final isSocietyPost = widget.post['society']?['name'] != null;
    final societyName =
        isSocietyPost ? widget.post['society']['name'] as String : '';
    final author = widget.post['author'] as Map<String, dynamic>? ?? {};
    final isOwnPost = author['_id'] == authUser?['_id'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mutedForeground.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: author['_id'] != null
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(userId: author['_id'] as String),
                      ),
                    )
                : null,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: author['profile']?['picture'] != null
                  ? NetworkImage(author['profile']['picture'] as String)
                  : const AssetImage('assets/default_profile_picture.png')
                      as ImageProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                                      userId: author['_id'] as String),
                                ),
                              )
                          : null,
                      child: Text(
                        author['name'] as String? ?? 'Deleted',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: foreground,
                        ),
                      ),
                    ),
                    if (isSocietyPost) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_right_alt,
                          size: 18, color: mutedForeground),
                      const SizedBox(width: 8),
                      Text(
                        societyName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: foreground,
                        ),
                      ),
                    ] else if (widget.flairType == Flairs.university.value) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.post['author']?['university']?['universityId']
                                  ?['name'] as String? ??
                              '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: mutedForeground,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: author['_id'] != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                      userId: author['_id'] as String),
                                ),
                              )
                          : null,
                      child: Text(
                        '@${author['username'] as String? ?? ''}',
                        style: TextStyle(
                          color: mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: mutedForeground,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    DateBadge(
                      date: formattedDate,
                      fontSize: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: foreground, size: 24),
            onSelected: (value) {
              final postId = widget.post['_id'] is Map
                  ? widget.post['_id']['id']
                  : widget.post['_id'];
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePost(
                      isEditing: true,
                      postData: widget.post,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteConfirmation(postId: postId);
              } else if (value == 'report') {
                _showReportDialog(postId);
              }
            },
            itemBuilder: (context) => isOwnPost
                ? [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, size: 20),
                        title: Text('Edit Post'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Post'),
                      ),
                    ),
                  ]
                : [
                    const PopupMenuItem(
                      value: 'report',
                      child: ListTile(
                        leading: Icon(Icons.report, color: Colors.blue),
                        title: Text('Report Post'),
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(Color foreground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.post['title'] != null)
          Text(
            widget.post['title'] as String,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: foreground,
            ),
          ),
        const SizedBox(height: 8),
        Text(
          widget.post['body'] as String? ?? '',
          style: TextStyle(
            fontSize: 16,
            color: foreground,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      Color foreground, Color mutedForeground, Color border) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: border, width: 0.5),
          bottom: BorderSide(color: border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PostStatItem(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            count: widget.post['voteId']?['upVotesCount'] ?? 0,
            onTap: () => _votePost('upvote'),
            isActive: isLiked,
          ),
          const SizedBox(width: 16),
          PostStatItem(
            icon: isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
            count: widget.post['voteId']?['downVotesCount'] ?? 0,
            onTap: () => _votePost('downvote'),
            isActive: isDisliked,
          ),
          const SizedBox(width: 16),
          PostStatItem(
            icon: Icons.chat_bubble_outline,
            count: widget.post['commentsCount'] ?? 0,
            onTap: () {},
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(
    Color foreground,
    Color mutedForeground,
    Color border,
    Color accent,
    Color background,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<dynamic>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load comments',
                  style: TextStyle(color: mutedForeground),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No comments yet',
                  style: TextStyle(color: mutedForeground),
                ),
              );
            }

            final comments = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => Divider(
                color: border,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final comment = comments[index];
                final author = comment['author'] as Map<String, dynamic>? ?? {};
                final voteId = comment['voteId'] as Map<String, dynamic>? ?? {};
                final commentId = comment['_id'] as String;
                final createdAt =
                    DateTime.parse(comment['createdAt'] as String);
                final timeAgo = timeago.format(createdAt, locale: 'en_short');
                final replyCount = (comment['replies'] as List?)?.length ?? 0;
                final isOwnComment = author['_id'] == authUser?['_id'];

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                                            userId: author['_id'] as String),
                                      ),
                                    )
                                : null,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: author['profile']?['picture'] !=
                                      null
                                  ? NetworkImage(
                                      author['profile']['picture'] as String)
                                  : const AssetImage(
                                          'assets/default_profile_picture.png')
                                      as ImageProvider,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
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
                                                  builder: (context) =>
                                                      ProfilePage(
                                                          userId: author['_id']
                                                              as String),
                                                ),
                                              )
                                          : null,
                                      child: Text(
                                        author['name'] as String? ?? 'Deleted',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: foreground,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '@${author['username'] as String? ?? ''} • $timeAgo',
                                      style: TextStyle(
                                        color: mutedForeground,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert,
                                color: foreground, size: 24),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteConfirmation(commentId: commentId);
                              } else if (value == 'report') {
                                _showReportDialog(commentId);
                              }
                            },
                            itemBuilder: (context) => isOwnComment
                                ? [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete,
                                            color: Colors.red),
                                        title: Text('Delete Comment'),
                                      ),
                                    ),
                                  ]
                                : [
                                    const PopupMenuItem(
                                      value: 'report',
                                      child: ListTile(
                                        leading: Icon(Icons.report,
                                            color: Colors.blue),
                                        title: Text('Report Comment'),
                                      ),
                                    ),
                                  ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 42),
                        child: Text(
                          comment['comment'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: foreground,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 42),
                        child: Row(
                          children: [
                            PostStatItem(
                              icon: _isCommentLiked[commentId] ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              count: voteId['upVotesCount'] ?? 0,
                              onTap: () => _voteComment(commentId, 'upvote'),
                              isActive: _isCommentLiked[commentId] ?? false,
                            ),
                            const SizedBox(width: 8),
                            PostStatItem(
                              icon: _isCommentDisliked[commentId] ?? false
                                  ? Icons.thumb_down
                                  : Icons.thumb_down_outlined,
                              count: voteId['downVotesCount'] ?? 0,
                              onTap: () => _voteComment(commentId, 'downvote'),
                              isActive: _isCommentDisliked[commentId] ?? false,
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommentRepliesPage(
                                      postId: widget.post['_id'] is Map
                                          ? widget.post['_id']['id']
                                          : widget.post['_id'],
                                      commentId: commentId,
                                      commentAuthor:
                                          author['name'] as String? ??
                                              'Deleted',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                replyCount == 0
                                    ? 'Reply'
                                    : '$replyCount repl${replyCount == 1 ? 'y' : 'ies'}',
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput(
    Color foreground,
    Color mutedForeground,
    Color border,
    Color accent,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: border, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: mutedForeground),
                filled: true,
                fillColor: accent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: foreground, width: 1),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: TextStyle(color: foreground, fontSize: 14),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isPostingComment
                ? null
                : () => _postComment(
                      widget.post['_id'] is Map
                          ? widget.post['_id']['id']
                          : widget.post['_id'],
                      _commentController.text,
                    ),
            icon: Icon(
              Icons.send,
              color: _isPostingComment ? mutedForeground : Colors.blueAccent,
              size: 24,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}



// class PostMedia extends StatelessWidget {
//   final List<dynamic> media;

//   const PostMedia({super.key, required this.media});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 200,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: media.length,
//         itemBuilder: (context, index) {
//           final mediaItem = media[index];
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: Image.network(
//               mediaItem['url'] as String? ?? '',
//               width: 200,
//               height: 200,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) =>
//                   const Icon(Icons.error, size: 50),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class PostStatItem extends StatelessWidget {
//   final IconData icon;
//   final int count;
//   final VoidCallback onTap;
//   final bool isActive;

//   const PostStatItem({
//     super.key,
//     required this.icon,
//     required this.count,
//     required this.onTap,
//     required this.isActive,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final foreground = isDark ? Colors.white : const Color(0xFF09090B);
//     final mutedForeground =
//         isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 20,
//             color: isActive ? Colors.blueAccent : mutedForeground,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             count.toString(),
//             style: TextStyle(
//               color: isActive ? Colors.blueAccent : mutedForeground,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class DateBadge extends StatelessWidget {
  final String date;
  final double fontSize;

  const DateBadge({super.key, required this.date, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedForeground =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Text(
      date,
      style: TextStyle(
        color: mutedForeground,
        fontSize: fontSize,
      ),
    );
  }
}
