import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/index.dart';
import 'package:socian/shared/services/api_client.dart';

class TeacherFeedbackDetailedPage extends StatefulWidget {
  final Map<String, dynamic> comment;
  final String teacherId;
  final bool isDark;

  const TeacherFeedbackDetailedPage({
    super.key,
    required this.comment,
    required this.teacherId,
    required this.isDark,
  });

  @override
  State<TeacherFeedbackDetailedPage> createState() =>
      _TeacherFeedbackDetailedPageState();
}

class _TeacherFeedbackDetailedPageState
    extends State<TeacherFeedbackDetailedPage> {
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

      log("response /api/teacher/reply/feedback: ${response.toString()}");
      setState(() {
        _replies = List<Map<String, dynamic>>.from(
            response['replies']['replies'] ?? []);
        // debugPrint("\n response _replies: ${_replies.toString()}");
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

  void _addReplyOptimistically(
      Map<String, dynamic> reply, String parentId, bool isReplyToReply) {
    setState(() {
      if (!isReplyToReply) {
        // If this is a new reply with a server-generated ID
        if (reply['_id'] != null && !reply['_id'].toString().contains('T')) {
          // Find and replace the temporary reply
          final index = _replies.indexWhere((r) =>
              r['_id'] != null &&
              r['_id'].toString().contains('T') &&
              r['comment'] == reply['comment']);
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
              r['comment'] == reply['comment']);
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

  void _removeOptimisticReply(
      String tempId, String parentId, bool isReplyToReply) {
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

  void _replaceReplyOptimistically(
      Map<String, dynamic> reply, String parentId, bool isReplyToReply) {
    print('reply: $reply The R is - ');

    print("The _replies is - ${_replies.toString()}");
    setState(() {
      final index = _replies.indexWhere((r) => r['_id'] == reply['_id']);
      if (index != -1) {
        _replies[index] = {
          ..._replies[index],
          'comment': reply['comment'],
          'gifUrl': reply['gifUrl'],
        };

        print("The _replies[index] is - ${_replies[index].toString()}");
        print("//////////////////////");
        print("The reply is - ${reply.toString()}");
        print("The index is - $index");

        print("//////////////////////------------");
        print("The _replies is - ${_replies.toString()}");
        print("//////////////////////------------");
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
    // debugPrint("_buildMainReplies: ${replies.toString()}");
    return replies
        .where((reply) => reply['_id'] != null)
        .map((reply) => RootReplyItem(
              reply: Map<String, dynamic>.from(reply),
              isDark: widget.isDark,
              teacherId: widget.teacherId,
              // onReaction: _handleReaction,
              onReplyAdded: _addReplyOptimistically,
              onReplyRemoved: _removeOptimisticReply,
              onReplyEdited: _replaceReplyOptimistically,
            ))
        .toList();
  }
}
