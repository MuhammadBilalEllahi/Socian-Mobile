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
        {}
      );
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

  Future<void> _upvoteComment(String commentId) async {
    try {
      await _apiClient.post(
        '/api/discussion/upvote/$commentId',
        {}
      );
      _fetchComments(); // Refresh comments to get updated vote counts
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upvote comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downvoteComment(String commentId) async {
    try {
      await _apiClient.post(
        '/api/discussion/downvote/$commentId',
        {}
      );
      _fetchComments(); // Refresh comments to get updated vote counts
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to downvote comment'),
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
      await _apiClient.post(
        '/api/discussion/add-comment',
        {
          'toBeDiscussedId': widget.toBeDiscussedId,
          'content': _commentController.text.trim(),
        }
      );
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
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        children: [
          if (comment['user']['_id'] == 'currentUserId') ...[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _editComment(comment);
              },
              child: const Text('Edit', style: TextStyle(color: Colors.white)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _deleteComment(comment['_id']);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _reportComment(comment['_id']);
            },
            child: const Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editComment(dynamic comment) {
    _commentController.text = comment['content'] ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Edit Comment', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _commentController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Edit your comment...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // Implement edit submission
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Delete Comment', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this comment?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // Implement delete submission
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _reportComment(String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Report Comment', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this comment?', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Inappropriate content', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement report submission
              },
            ),
            ListTile(
              title: const Text('Spam', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement report submission
              },
            ),
            ListTile(
              title: const Text('Harassment', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement report submission
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _addReply(String parentCommentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Add Reply', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _replyController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type your reply...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // Implement reply submission
              Navigator.pop(context);
            },
            child: const Text('Reply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(dynamic comment) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[800]!, width: 1),
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
                  backgroundImage: NetworkImage(comment['user']['profile']?.toString() ?? ''),
                  backgroundColor: Colors.grey[800],
                ),
                const SizedBox(width: 8),
                Text(
                  comment['user']['username']?.toString() ?? 'Anonymous',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showMoreOptions(comment),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment['content']?.toString() ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up_outlined, color: Colors.grey[400], size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _upvoteComment(comment['_id'].toString()),
                ),
                Text(
                  comment['voteId']['upVotesCount']?.toString() ?? '0',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.thumb_down_outlined, color: Colors.grey[400], size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _downvoteComment(comment['_id'].toString()),
                ),
                Text(
                  comment['voteId']['downVotesCount']?.toString() ?? '0',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
                      Icon(Icons.reply, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 4),
                      Text('Reply', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
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
    return Container(
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Comments list
          Expanded(
            child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : comments.isEmpty
                ? const Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentCard(comments[index]);
                    },
                  ),
          ),
          // Add comment section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
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