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
          const SnackBar(content: Text('Invalid route arguments or missing ID')),
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
        '/discussion/create-get?toBeDisccusedId=${widget.toBeDiscussedId}',
        {}
      );
      setState(() {
        comments = response['discussion']['discussioncomments'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load comments')),
      );
    }
  }

  void _showMoreOptions(dynamic comment) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          if (comment['user']['_id'] == 'currentUserId') ...[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _editComment(comment);
              },
              child: const Text('Edit'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _deleteComment(comment['_id']);
              },
              child: const Text('Delete'),
            ),
          ],
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _reportComment(comment['_id']);
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _editComment(dynamic comment) {
    // Implement edit functionality
  }

  void _deleteComment(String commentId) {
    // Implement delete functionality
  }

  void _reportComment(String commentId) {
    // Implement report functionality
  }

  void _addReply(String parentCommentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reply'),
        content: TextField(
          controller: _replyController,
          decoration: const InputDecoration(hintText: 'Type your reply...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement reply submission
              Navigator.pop(context);
            },
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(comment['user']['profile'] ?? ''),
                            ),
                            const SizedBox(width: 8),
                            Text(comment['user']['username'] ?? 'Anonymous'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showMoreOptions(comment),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(comment['content'] ?? ''),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up),
                              onPressed: () {
                                // Implement upvote
                              },
                            ),
                            Text('${comment['voteId']['upVotesCount']}'),
                            IconButton(
                              icon: const Icon(Icons.thumb_down),
                              onPressed: () {
                                // Implement downvote
                              },
                            ),
                            Text('${comment['voteId']['downVotesCount']}'),
                            TextButton(
                              onPressed: () => _addReply(comment['_id']),
                              child: const Text('Reply'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add new comment
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
