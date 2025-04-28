import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/drawer/student/pages/pastPaper/discussion/answerPage/components/AddAnswer.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';

class Comments extends StatefulWidget {
  final String toBeDiscussedId;

  const Comments({super.key, required this.toBeDiscussedId});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> comments = [];
  bool isLoading = true;
  final TextEditingController _replyController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  List<dynamic> _cachedComments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.toBeDiscussedId.isNotEmpty) {
      if (_cachedComments.isEmpty) {
        _fetchComments();
      }
    } else {
      setState(() {
        comments = [];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid route arguments or missing ID'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final response = await _apiClient.post(
          '/api/discussion/create-get?toBeDisccusedId=${widget.toBeDiscussedId}',
          {});
      debugPrint("COMMENTS: $response");
      setState(() {
        comments = response['discussion']['discussioncomments'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load comments'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _voteComment(String commentId, EnumVoteType voteType) async {
    try {
      await _apiClient.post('/api/discussion/comment/vote',
          {'commentId': commentId, 'voteType': voteType.name});
      // debugPrint("VOTE TYPE ${voteType.name}");
      _fetchComments(); // Refresh comments to get updated vote counts
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${voteType.name} comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addNewComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _apiClient.post('/api/discussion/comment/add-comment', {
        'toBeDiscussedId': widget.toBeDiscussedId,
        'commentContent': _commentController.text.trim(),
      });
      _commentController.clear();
      _fetchComments(); // Refresh comments to show the new one
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMoreOptions(dynamic comment) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        children: [
          if (comment['user']['_id'] == 'currentUserId') ...[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _editComment(comment);
              },
              child: Text('Edit', style: TextStyle(color: foreground)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _deleteComment(comment['_id']);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _reportComment(comment['_id']);
            },
            child: Text('Report', style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }

  void _editComment(dynamic comment) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    _commentController.text = comment['content'] ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        title: Text('Edit Comment', style: TextStyle(color: foreground)),
        content: TextField(
          controller: _commentController,
          style: TextStyle(color: foreground),
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
            hintStyle: TextStyle(color: mutedForeground),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: border),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: border),
              borderRadius: BorderRadius.circular(8),
            ),
            fillColor: accent,
            filled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: mutedForeground)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: muted,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }

  void _deleteComment(String commentId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        title: Text('Delete Comment', style: TextStyle(color: foreground)),
        content: Text('Are you sure you want to delete this comment?',
            style: TextStyle(color: foreground)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: mutedForeground)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _reportComment(String commentId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        title: Text('Report Comment', style: TextStyle(color: foreground)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting this comment?',
                style: TextStyle(color: foreground)),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Inappropriate content',
                  style: TextStyle(color: foreground)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Spam', style: TextStyle(color: foreground)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Harassment', style: TextStyle(color: foreground)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: mutedForeground)),
          ),
        ],
      ),
    );
  }

  void _addReply(String parentCommentId) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border),
        ),
        title: Text('Add Reply', style: TextStyle(color: foreground)),
        content: TextField(
          controller: _replyController,
          style: TextStyle(color: foreground),
          decoration: InputDecoration(
            hintText: 'Type your reply...',
            hintStyle: TextStyle(color: mutedForeground),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: border),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: border),
              borderRadius: BorderRadius.circular(8),
            ),
            fillColor: accent,
            filled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: mutedForeground)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: muted,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _apiClient.post('/api/discussion/comment/reply-to-comment', {
                'commentId': parentCommentId,
                'replyContent': _replyController.text
              });
            },
            child: Text('Reply', style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(dynamic comment) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Card(
      color: accent,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                      comment['user']['profile']?.toString() ?? ''),
                  backgroundColor: muted,
                ),
                const SizedBox(width: 8),
                Text(
                  comment['user']['username']?.toString() ?? 'Anonymous',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: mutedForeground, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showMoreOptions(comment),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment['content']?.toString() ?? '',
              style: TextStyle(
                color: foreground,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up_outlined,
                      color: mutedForeground, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _voteComment(
                      comment['_id'].toString(), EnumVoteType.upvote),
                ),
                Text(
                  comment['voteId']['upVotesCount']?.toString() ?? '0',
                  style: TextStyle(color: mutedForeground, fontSize: 12),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.thumb_down_outlined,
                      color: mutedForeground, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _voteComment(
                      comment['_id'].toString(), EnumVoteType.downvote),
                ),
                Text(
                  comment['voteId']['downVotesCount']?.toString() ?? '0',
                  style: TextStyle(color: mutedForeground, fontSize: 12),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _addReply(comment['_id'].toString()),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reply, color: mutedForeground, size: 16),
                      const SizedBox(width: 4),
                      Text('Reply',
                          style:
                              TextStyle(color: mutedForeground, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            if (comment['replies'] != null && comment['replies'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Column(
                  children: [
                    for (var reply in comment['replies'])
                      _buildCommentCard(reply)
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Container(
      color: background,
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  )
                : comments.isEmpty
                    ? Center(
                        child: Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(color: mutedForeground),
                        ),
                      )
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return _buildCommentCard(comments[index]);
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: TextStyle(color: foreground),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: mutedForeground),
                      filled: true,
                      fillColor: accent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                        borderSide: BorderSide(color: border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: foreground),
                  onPressed: _addNewComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
