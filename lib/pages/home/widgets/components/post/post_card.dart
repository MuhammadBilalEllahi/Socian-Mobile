import 'package:beyondtheclass/pages/profile/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'date_badge.dart';
import 'post_media.dart';
import 'post_stat_item.dart';

class PostCard extends StatefulWidget {
  final dynamic post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isDisliked = false;
  bool isVoting = false;
  final _apiClient = ApiClient();

  Future<void> _votePost(String voteType) async {
    if (isVoting) return;

    setState(() {
      isVoting = true;
    });

    try {
      final response = await _apiClient.post('/api/posts/vote-post', {
        'postId': widget.post['_id'],
        'voteType': voteType,
      });

      debugPrint('Vote response: $response');

      setState(() {
        widget.post['voteId']['upVotesCount'] = response['upVotesCount'];
        widget.post['voteId']['downVotesCount'] = response['downVotesCount'];

        if (response['noneSelected'] == true) {
          isLiked = false;
          isDisliked = false;
        } else {
          isLiked = voteType == 'upvote' && response['noneSelected'] != true;
          isDisliked = voteType == 'downvote' && response['noneSelected'] != true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    } catch (e) {
      debugPrint('Error voting: $e');
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
      final response = await _apiClient.delete('/api/posts/delete', queryParameters: {
        'postId': postId,
      });
      debugPrint('Delete post response: $response');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(String postId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
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
      await _deletePost(postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(0, 0, 0, 0) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(post: widget.post),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(isDark, formattedDate),
                const SizedBox(height: 8),
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

  Widget _buildUserInfo(bool isDark, String formattedDate) {
    final isSocietyPost = widget.post['society'] != null && widget.post['society']['name'] != null;
    final societyName = isSocietyPost ? widget.post['society']['name'] : '';
    final author = widget.post['author'] ?? {};

    return Row(
      children: [
        GestureDetector(
          onTap: author['_id'] != null && author['username']?.isNotEmpty == true
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: author['_id']),
                    ),
                  );
                }
              : null,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            backgroundImage: author['profile'] != null
                ? NetworkImage(author['profile']['picture'] ?? '')
                : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
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
                    onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(userId: author['_id']),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      author['name'] ?? '{Deleted}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (isSocietyPost) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_right,
                      size: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      societyName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  GestureDetector(
                    onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(userId: author['_id']),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      '@${author['username'] ?? ''}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DateBadge(date: formattedDate),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () async {
            final currentUserId = await _apiClient.getCurrentUserId();
            if (author['_id'] == currentUserId) {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
            }
          },
        ),
      ],
    );
  }

  Widget _buildPostContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
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
          const SizedBox(height: 8),
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
                builder: (context) => PostDetailPage(post: widget.post),
              ),
            );
          },
          isActive: false,
        ),
        ],
    );
  }
}

class PostDetailPage extends StatefulWidget {
  final dynamic post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
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

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments(widget.post['_id']);
  }

  Future<void> _votePost(String voteType) async {
    if (isVoting) return;

    setState(() {
      isVoting = true;
    });

    try {
      final response = await _apiClient.post('/api/posts/vote-post', {
        'postId': widget.post['_id'],
        'voteType': voteType,
      });

      debugPrint('Vote response: $response');

      setState(() {
        widget.post['voteId']['upVotesCount'] = response['upVotesCount'];
        widget.post['voteId']['downVotesCount'] = response['downVotesCount'];

        if (response['noneSelected'] == true) {
          isLiked = false;
          isDisliked = false;
        } else {
          isLiked = voteType == 'upvote' && response['noneSelected'] != true;
          isDisliked = voteType == 'downvote' && response['noneSelected'] != true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    } catch (e) {
      debugPrint('Error voting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: $e')),
      );
    } finally {
      setState(() {
        isVoting = false;
      });
    }
  }

  Future<void> _voteComment(String commentId, String voteType) async {
    if (_isCommentVoting[commentId] == true) return;

    setState(() {
      _isCommentVoting[commentId] = true;
    });

    try {
      final response = await _apiClient.post('/api/posts/post/comment/vote', {
        'commentId': commentId,
        'voteType': voteType,
      });

      debugPrint('Comment vote response: $response');

      setState(() {
        final commentIndex = _comments.indexWhere((c) => c['_id'] == commentId);
        if (commentIndex != -1) {
          _comments[commentIndex]['voteId']['upVotesCount'] = response['upVotesCount'];
          _comments[commentIndex]['voteId']['downVotesCount'] = response['downVotesCount'];

          if (response['noneSelected'] == true) {
            _isCommentLiked[commentId] = false;
            _isCommentDisliked[commentId] = false;
          } else {
            _isCommentLiked[commentId] = voteType == 'upvote' && response['noneSelected'] != true;
            _isCommentDisliked[commentId] = voteType == 'downvote' && response['noneSelected'] != true;
          }
        } else {
          debugPrint('Comment with ID $commentId not found in _comments');
          _refreshComments();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    } catch (e) {
      debugPrint('Error voting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote comment: $e')),
      );
    } finally {
      setState(() {
        _isCommentVoting[commentId] = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      final response = await _apiClient.delete('/api/posts/delete', queryParameters: {
        'postId': postId,
      });
      debugPrint('Delete post response: $response');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final response = await _apiClient.delete('/api/posts/post/comment', queryParameters: {
        'commentId': commentId,
      });
      debugPrint('Delete comment response: $response');
      setState(() {
        _comments.removeWhere((c) => c['_id'] == commentId);
        widget.post['commentsCount'] = (widget.post['commentsCount'] ?? 1) - 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully')),
      );
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmation({String? postId, String? commentId}) async {
    final isPost = postId != null;
    final id = postId ?? commentId!;
    final type = isPost ? 'Post' : 'Comment';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $type'),
        content: Text('Are you sure you want to delete this $type? This action cannot be undone.'),
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
      _commentsFuture = _fetchComments(widget.post['_id']);
    });
  }

  Future<List<dynamic>> _fetchComments(String postId) async {
    try {
      final response = await _apiClient.getList('/api/posts/post/comments', queryParameters: {
        'postId': postId,
      });
      debugPrint('Comments response: $response');
      if (response is List && response.isNotEmpty) {
        final comments = response[0]['comments']?.where((c) => !(c['isDeleted'] ?? false)).toList() ?? [];
        setState(() {
          _comments = comments;
        });
        return comments;
      } else if (response is String) {
        debugPrint('Unexpected string response: $response');
        throw Exception('Unexpected string response: $response');
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<void> _postComment(String postId, String comment) async {
    if (comment.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    setState(() {
      _isPostingComment = true;
    });

    try {
      final response = await _apiClient.post('/api/posts/post/comment', {
        'postId': postId,
        'comment': comment,
      });
      debugPrint('Post comment response: $response');
      _commentController.clear();
      setState(() {
        widget.post['commentsCount'] = (widget.post['commentsCount'] ?? 0) + 1;
      });
      await _refreshComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully')),
      );
    } catch (e) {
      debugPrint('Error posting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    } finally {
      setState(() {
        _isPostingComment = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDark ? Colors.white : const Color(0xFF09090B);
    final muted = isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent = isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Post',
          style: TextStyle(color: foreground),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(foreground, mutedForeground, formattedDate),
              const SizedBox(height: 16),
              _buildPostContent(foreground),
              if (media != null && media.isNotEmpty) ...[
                const SizedBox(height: 16),
                PostMedia(media: media),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(foreground, mutedForeground),
              const SizedBox(height: 16),
              _buildCommentsSection(foreground, mutedForeground, border, accent, background),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(Color foreground, Color mutedForeground, String formattedDate) {
    final isSocietyPost = widget.post['society'] != null && widget.post['society']['name'] != null;
    final societyName = isSocietyPost ? widget.post['society']['name'] : '';
    final author = widget.post['author'] ?? {};

    return Row(
      children: [
        GestureDetector(
          onTap: author['_id'] != null && author['username']?.isNotEmpty == true
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: author['_id']),
                    ),
                  );
                }
              : null,
          child: CircleAvatar(
            radius: 24,
            backgroundImage: author['profile'] != null
                ? NetworkImage(author['profile']['picture'] ?? '')
                : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
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
                    onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(userId: author['_id']),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      author['name'] ?? '{Deleted}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: foreground,
                      ),
                    ),
                  ),
                  if (isSocietyPost) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_right,
                      size: 20,
                      color: foreground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      societyName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: foreground,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  GestureDetector(
                    onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(userId: author['_id']),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      '@${author['username'] ?? ''}',
                      style: TextStyle(
                        color: mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mutedForeground,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DateBadge(date: formattedDate),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: foreground,
            size: 24,
          ),
          onPressed: () async {
            final currentUserId = await _apiClient.getCurrentUserId();
            if (author['_id'] == currentUserId) {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Delete Post'),
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(postId: widget.post['_id']);
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
    );
  }

  Widget _buildPostContent(Color foreground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post['title'] ?? '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: foreground,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.post['body'] ?? '',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color foreground, Color mutedForeground) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          onTap: () {},
          isActive: false,
        ),
        PostStatItem(
          icon: Icons.repeat,
          count: 0,
          onTap: () {
            // TODO: Implement repost
          },
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildCommentsSection(Color foreground, Color mutedForeground, Color border, Color accent, Color background) {
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
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
              onPressed: _isPostingComment
                  ? null
                  : () => _postComment(widget.post['_id'], _commentController.text),
              style: TextButton.styleFrom(
                backgroundColor: foreground,
                foregroundColor: background,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isPostingComment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                height: 24,
              ),
              itemBuilder: (context, index) {
                final comment = comments[index];
                final author = comment['author'] ?? {};
                final voteId = comment['voteId'] ?? {};
                final commentId = comment['_id'];
                final createdAt = DateTime.parse(comment['createdAt']);
                final timeAgo = timeago.format(createdAt, locale: 'en_short');
                final replyCount = (comment['replies'] as List?)?.length ?? 0;

                _isCommentLiked[commentId] ??= false;
                _isCommentDisliked[commentId] ??= false;
                _isCommentVoting[commentId] ??= false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(userId: author['_id']),
                                    ),
                                  );
                                }
                              : null,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: author['profile'] != null
                                ? NetworkImage(author['profile']['picture'] ?? '')
                                : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(userId: author['_id']),
                                          ),
                                        );
                                      }
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
                              GestureDetector(
                                onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(userId: author['_id']),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text(
                                  '@${author['username'] ?? ''} • $timeAgo',
                                  style: TextStyle(
                                    color: mutedForeground,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: mutedForeground,
                            size: 20,
                          ),
                          onPressed: () async {
                            final currentUserId = await _apiClient.getCurrentUserId();
                            if (author['_id'] == currentUserId) {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.delete, color: Colors.red),
                                        title: const Text('Delete Comment'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _showDeleteConfirmation(commentId: commentId);
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
                      comment['comment'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: foreground,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PostStatItem(
                          icon: _isCommentLiked[commentId]! ? Icons.favorite : Icons.favorite_outline,
                          count: voteId['upVotesCount'] ?? 0,
                          onTap: () => _voteComment(commentId, 'upvote'),
                          isActive: _isCommentLiked[commentId]!,
                        ),
                        const SizedBox(width: 16),
                        PostStatItem(
                          icon: _isCommentDisliked[commentId]! ? Icons.thumb_down : Icons.thumb_down_outlined,
                          count: voteId['downVotesCount'] ?? 0,
                          onTap: () => _voteComment(commentId, 'downvote'),
                          isActive: _isCommentDisliked[commentId]!,
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentRepliesPage(
                                  postId: widget.post['_id'],
                                  commentId: commentId,
                                  commentAuthor: author['name'] ?? '{Deleted}',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            replyCount == 0 ? 'Reply' : '$replyCount repl${replyCount == 1 ? 'y' : 'ies'}',
                            style: TextStyle(
                              color: mutedForeground,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class CommentRepliesPage extends StatefulWidget {
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
  State<CommentRepliesPage> createState() => _CommentRepliesPageState();
}

class _CommentRepliesPageState extends State<CommentRepliesPage> {
  final _apiClient = ApiClient();
  final _replyController = TextEditingController();
  bool _isPostingReply = false;
  final Map<String, bool> _isReplyLiked = {};
  final Map<String, bool> _isReplyDisliked = {};
  final Map<String, bool> _isReplyVoting = {};
  List<dynamic> _replies = [];
  late Future<List<dynamic>> _repliesFuture;

  @override
  void initState() {
    super.initState();
    _repliesFuture = _fetchReplies(widget.commentId);
  }

  Future<List<dynamic>> _fetchReplies(String commentId) async {
    try {
      final response = await _apiClient.getList('/api/posts/post/comment/replies', queryParameters: {
        'commentId': commentId,
      });
      debugPrint('Replies response: $response');
      final replies = response?.where((r) => !(r['isDeleted'] ?? false)).toList() ?? [];
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

  Future<void> _postReply(String postId, String commentId, String comment) async {
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

  Future<void> _voteReply(String replyId, String voteType) async {
    if (_isReplyVoting[replyId] == true) return;

    setState(() {
      _isReplyVoting[replyId] = true;
    });

    try {
      final response = await _apiClient.post('/api/posts/post/comment/vote', {
        'commentId': replyId,
        'voteType': voteType,
      });

      debugPrint('Reply vote response: $response');

      setState(() {
        final replyIndex = _replies.indexWhere((r) => r['_id'] == replyId);
        if (replyIndex != -1) {
          _replies[replyIndex]['voteId']['upVotesCount'] = response['upVotesCount'];
          _replies[replyIndex]['voteId']['downVotesCount'] = response['downVotesCount'];
        }
        _isReplyLiked[replyId] = voteType == 'upvote' && response['noneSelected'] != true;
        _isReplyDisliked[replyId] = voteType == 'downvote' && response['noneSelected'] != true;
        if (response['noneSelected'] == true) {
          _isReplyLiked[replyId] = false;
          _isReplyDisliked[replyId] = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    } catch (e) {
      debugPrint('Error voting reply: $e');
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
      final response = await _apiClient.delete('/api/posts/post/reply/comment', queryParameters: {
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
        content: const Text('Are you sure you want to delete this reply? This action cannot be undone.'),
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
    final mutedForeground = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
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
          icon: Icon(
            Icons.arrow_back,
            color: foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Replies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
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
                        : () => _postReply(widget.postId, widget.commentId, _replyController.text),
                    style: TextButton.styleFrom(
                      backgroundColor: foreground,
                      foregroundColor: background,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        : const Text(
                            'Post',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                      child: Text(
                        'Failed to load replies',
                        style: TextStyle(color: mutedForeground),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No replies yet',
                        style: TextStyle(color: mutedForeground),
                      ),
                    );
                  }

                  final replies = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: replies.length,
                    separatorBuilder: (context, index) => Divider(
                      color: border,
                      height: 24,
                    ),
                    itemBuilder: (context, index) {
                      final reply = replies[index];
                      final author = reply['author'] ?? {};
                      final voteId = reply['voteId'] ?? {};
                      final replyId = reply['_id'];
                      final createdAt = DateTime.parse(reply['createdAt']);
                      final timeAgo = timeago.format(createdAt, locale: 'en_short');

                      _isReplyLiked[replyId] ??= false;
                      _isReplyDisliked[replyId] ??= false;
                      _isReplyVoting[replyId] ??= false;

                      return Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProfilePage(userId: author['_id']),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: author['profile'] != null
                                        ? NetworkImage(author['profile']['picture'] ?? '')
                                        : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProfilePage(userId: author['_id']),
                                                  ),
                                                );
                                              }
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
                                      GestureDetector(
                                        onTap: author['_id'] != null && author['username']?.isNotEmpty == true
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProfilePage(userId: author['_id']),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Text(
                                          '@${author['username'] ?? ''} • $timeAgo',
                                          style: TextStyle(
                                            color: mutedForeground,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: mutedForeground,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final currentUserId = await _apiClient.getCurrentUserId();
                                    if (author['_id'] == currentUserId) {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.delete, color: Colors.red),
                                                title: const Text('Delete Reply'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _showDeleteConfirmation(replyId);
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
                                fontSize: 14,
                                color: foreground,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                PostStatItem(
                                  icon: _isReplyLiked[replyId]! ? Icons.favorite : Icons.favorite_outline,
                                  count: voteId['upVotesCount'] ?? 0,
                                  onTap: () => _voteReply(replyId, 'upvote'),
                                  isActive: _isReplyLiked[replyId]!,
                                ),
                                const SizedBox(width: 16),
                                PostStatItem(
                                  icon: _isReplyDisliked[replyId]! ? Icons.thumb_down : Icons.thumb_down_outlined,
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
      ),
    );
  }
}