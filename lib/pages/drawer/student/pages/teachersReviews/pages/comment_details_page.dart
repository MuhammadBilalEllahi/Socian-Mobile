import 'package:flutter/material.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'commentDetailed/widgets/index.dart';

class CommentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> comment;
  final String teacherId;
  final bool isDark;

  const CommentDetailsPage({
    super.key,
    required this.comment,
    required this.teacherId,
    required this.isDark,
  });

  @override
  State<CommentDetailsPage> createState() => _CommentDetailsPageState();
}

class _CommentDetailsPageState extends State<CommentDetailsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _replies = [];
  // bool _isNestedView = true;
  final Map<String, bool> _showNestedReplies = {};
  final Map<String, List<Map<String, dynamic>>> _nestedRepliesCache = {};

  @override
  void initState() {
    super.initState();
    _fetchReplies();
  }

  Future<void> _fetchReplies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ApiClient apiClient = ApiClient();
      final response = await apiClient.get(
        '/api/teacher/reply/feedback',
        queryParameters: {'feedbackCommentId': widget.comment['_id']},
      );

      debugPrint("response /api/teacher/reply/feedback: ${response.toString()}");
      setState(() {
        _replies = List<Map<String, dynamic>>.from(response['replies']['replies'] ?? []);
        debugPrint("\n response _replies: ${_replies.toString()}");
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load replies: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleVote(String commentId, bool isUpvote) async {
    try {
      final ApiClient apiClient = ApiClient();
      await apiClient.post(
        '/api/teacher/feedback/vote',
        {
          'feedbackId': commentId,
          'voteType': isUpvote ? 'upvote' : 'downvote',
        },
      );
      _fetchReplies();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to vote: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleReaction(String replyId, String reactionType) async {
    try {
      final ApiClient apiClient = ApiClient();
      await apiClient.post(
        '/api/teacher/reply/react',
        {
          'replyId': replyId,
          'reactionType': reactionType,
        },
      );
      _fetchReplies();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to react: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addReplyOptimistically(Map<String, dynamic> reply, String parentId, bool isReplyToReply) {
    setState(() {
      if (!isReplyToReply) {
        // If this is a new reply with a server-generated ID
        if (reply['_id'] != null && !reply['_id'].toString().contains('T')) {
          // Find and replace the temporary reply
          final index = _replies.indexWhere((r) => 
            r['_id'] != null && 
            r['_id'].toString().contains('T') && 
            r['comment'] == reply['comment']
          );
          if (index != -1) {
            _replies[index] = reply;
          } else {
            _replies.add(reply);
          }
        } else {
          // Add new optimistic reply
          _replies.add(reply);
        }
      } else {
        final nestedReplies = _nestedRepliesCache[parentId] ?? [];
        // If this is a new reply with a server-generated ID
        if (reply['_id'] != null && !reply['_id'].toString().contains('T')) {
          // Find and replace the temporary reply
          final index = nestedReplies.indexWhere((r) => 
            r['_id'] != null && 
            r['_id'].toString().contains('T') && 
            r['comment'] == reply['comment']
          );
          if (index != -1) {
            nestedReplies[index] = reply;
          } else {
            nestedReplies.add(reply);
          }
        } else {
          // Add new optimistic reply
          nestedReplies.add(reply);
        }
        _nestedRepliesCache[parentId] = nestedReplies;
        _showNestedReplies[parentId] = true;
      }
    });
  }

  void _removeOptimisticReply(String tempId, String parentId, bool isReplyToReply) {
    setState(() {
      if (!isReplyToReply) {
        _replies.removeWhere((r) => r['_id'] == tempId);
      } else {
        final nestedReplies = _nestedRepliesCache[parentId] ?? [];
        nestedReplies.removeWhere((r) => r['_id'] == tempId);
        _nestedRepliesCache[parentId] = nestedReplies;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Comment Details'),
        backgroundColor: widget.isDark ? Colors.black : Colors.white,
      ),
      body: ListView(
        children: [
          // Original Comment
          Container(
            margin: const EdgeInsets.only(bottom: 1),
            color: widget.isDark ? Colors.black : Colors.white,
            child: OriginalComment(
              comment: widget.comment,
              teacherId: widget.teacherId,
              isDark: widget.isDark,
              onVote: _handleVote,
              onReplyAdded: _addReplyOptimistically,
              onReplyRemoved: _removeOptimisticReply,
            ),
          ),

          // Replies Section
          Container(
            color: widget.isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replies',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_replies.isEmpty)
                  Center(
                    child: Text(
                      'No replies yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  )
                else
                  Column(
                    children: _buildMainReplies(_replies),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMainReplies(List<Map<String, dynamic>> replies) {
    debugPrint("_buildMainReplies: ${replies.toString()}");
    return replies.where((reply) => 
      reply['_id'] != null
    ).map((reply) => ReplyItem(
      reply: Map<String, dynamic>.from(reply),
      isDark: widget.isDark,
      teacherId: widget.teacherId,
      onReaction: _handleReaction,
      onReplyAdded: _addReplyOptimistically,
      onReplyRemoved: _removeOptimisticReply,
    )).toList();
  }
} 