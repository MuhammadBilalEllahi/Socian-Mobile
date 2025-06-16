import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/core/utils/rbac.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/widgets/EditFeedBackSheet.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/widgets/TeacherMainPageComments.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/widgets/my_snackbar.dart';
import 'package:socian/utils/date_formatter.dart';

import 'ReplyBox.dart';
import 'vote_button.dart';

class OriginalComment extends ConsumerStatefulWidget {
  final Map<String, dynamic> comment;
  final String teacherId;
  final bool isDark;
  final Function(Map<String, dynamic>, String, bool) onReplyAdded;
  final Function(String, String, bool) onReplyRemoved;

  const OriginalComment({
    super.key,
    required this.comment,
    required this.teacherId,
    required this.isDark,
    required this.onReplyAdded,
    required this.onReplyRemoved,
  });

  @override
  ConsumerState<OriginalComment> createState() => _OriginalCommentState();
}

class _OriginalCommentState extends ConsumerState<OriginalComment> {
  bool _isVoting = false;
  int? _upVotesCount;
  int? _downVotesCount;
  String? _userVote; // 'upvote', 'downvote', or null

  @override
  void initState() {
    super.initState();
    _upVotesCount = widget.comment['upVotesCount'] ?? 0;
    _downVotesCount = widget.comment['downVotesCount'] ?? 0;
    // Optionally, you can track user's previous vote if available in comment
    // _userVote = widget.comment['userVote'];
  }

  Future<void> _handleVote(
      String commentId, String userIdOther, String voteType) async {
    if (_isVoting) return;
    setState(() {
      _isVoting = true;
      // Optimistic update
      if (_userVote == voteType) {
        // Undo vote
        if (voteType == 'upvote') _upVotesCount = (_upVotesCount ?? 1) - 1;
        if (voteType == 'downvote')
          _downVotesCount = (_downVotesCount ?? 1) - 1;
        _userVote = null;
      } else {
        if (voteType == 'upvote') {
          _upVotesCount = (_upVotesCount ?? 0) + 1;
          if (_userVote == 'downvote')
            _downVotesCount = (_downVotesCount ?? 1) - 1;
        } else if (voteType == 'downvote') {
          _downVotesCount = (_downVotesCount ?? 0) + 1;
          if (_userVote == 'upvote') _upVotesCount = (_upVotesCount ?? 1) - 1;
        }
        _userVote = voteType;
      }
    });
    try {
      final ApiClient apiClient = ApiClient();
      final response = await apiClient.post(
        '/api/teacher/reviews/feedbacks/vote',
        {
          'reviewId': commentId,
          'userIdOther': userIdOther,
          'voteType': voteType,
        },
      );
      log('[VOTE] RESPONSE FROM VOTE $response');
      if (mounted) {
        setState(() {
          _upVotesCount = response['upVotesCount'] ?? _upVotesCount;
          _downVotesCount = response['downVotesCount'] ?? _downVotesCount;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote submitted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Revert optimistic update
      setState(() {
        // Re-fetch from widget.comment in case of error
        _upVotesCount = widget.comment['upVotesCount'] ?? 0;
        _downVotesCount = widget.comment['downVotesCount'] ?? 0;
        // _userVote = widget.comment['userVote']; // If you have this info
        _userVote = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to vote: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  final _reasonController = TextEditingController();

  Widget _hideReasonDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: const Text('Hide Reason', style: TextStyle(fontSize: 16)),
      content: TextFormField(
        controller: _reasonController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter reason for hiding',
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a reason';
          }
          return null;
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black)),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, _reasonController.text.trim()),
          child: Text('Submit',
              style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white : Colors.black)),
        ),
      ],
    );
  }

  Future<void> _handleHide() async {
    // Handle hide
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _hideReasonDialog(),
    );
    if (reason == null) return;
    final apiClient = ApiClient();
    try {
      final response = await apiClient.post(
        '/api/mod/teacher/reviews/feedback/hide',
        {
          'reviewId': widget.comment['_id'],
          'reason': reason,
        },
      );
      if (response.isNotEmpty) {
        showSnackbar(context, response['message'], isError: false);
      }
    } catch (e) {
      showSnackbar(context, e.toString(), isError: true);
    }
  }

  Future<void> _handleDelete() async {
    // Handle delete
    final apiClient = ApiClient();
    try {
      final response = await apiClient.delete(
        '/api/teacher/reviews/feedbacks/delete?teacherId=${widget.teacherId}&reviewId=${widget.comment['_id']}',
      );
      if (response.isNotEmpty) {
        if (mounted) {
          showSnackbar(context, response['message'], isError: false);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, e.toString(), isError: true);
      }
    }
  }

  void _handleEdit(Map<String, dynamic> comment) {
    // Get the parent widget's state
    final parentState =
        context.findAncestorStateOfType<TeacherMainPageCommentsState>();

    print("comment $comment");
    // Handle edit
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditFeedBackSheet(
          teacherId: widget.teacherId,
          editComment: comment,
          onOptimisticComment: (optimisticComment,
              {required Future<bool> Function() confirm}) {
            parentState?.addOptimisticComment(
              optimisticComment,
              confirm: confirm,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comment = widget.comment;
    final userRef = ref.read(authProvider).user;
    final user = comment['user'];
    final name = user['name'] ?? 'Anonymous';
    final isDeleted = user['_id'] == null;
    final isAnonymous = comment['isAnonymous'] ?? false;
    log("WELLxLL $comment");

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: widget.isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                child: Text(
                  name[0].toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isAnonymous ? 'Anonymous' : name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDeleted
                                    ? theme.colorScheme.onSurface
                                        .withOpacity(0.5)
                                    : null,
                              ),
                            ),
                            if (!isDeleted &&
                                !isAnonymous &&
                                user['isVerified'] == true) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Colors.blue,
                              ),
                            ],
                            if (user['_id'] == userRef?['_id']) ...[
                              const SizedBox(width: 4),
                              const Text('(You)'),
                            ],
                          ],
                        ),
                        // Rating Stars
                        if (comment['rating'] != null)
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < (comment['rating'] as int)
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 16,
                                color: index < (comment['rating'] as int)
                                    ? const Color(0xFFFFD700)
                                    : widget.isDark
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.3),
                              );
                            }),
                          ),
                      ],
                    ),
                    Text(
                      comment['updatedAt'] != null
                          ? DateFormatter.formatDate(comment['updatedAt'])
                          : '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              comment['feedback'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              children: [
                VoteButton(
                  icon: Icons.arrow_upward_rounded,
                  count: _upVotesCount ?? 0,
                  isDark: widget.isDark,
                  onPressed: _isVoting
                      ? null
                      : (() => _handleVote(
                              comment['_id'], comment['user']['_id'], 'upvote'))
                          as VoidCallback?,
                ),
                const SizedBox(width: 16),
                VoteButton(
                  icon: Icons.arrow_downward_rounded,
                  count: _downVotesCount ?? 0,
                  isDark: widget.isDark,
                  onPressed: _isVoting
                      ? null
                      : (() => _handleVote(comment['_id'],
                          comment['user']['_id'], 'downvote')) as VoidCallback?,
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: widget.isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: widget.isDark ? Colors.grey[900] : Colors.white,
                  elevation: 4,
                  itemBuilder: (context) => [
                    if (widget.comment['user']?['_id'] == userRef?['_id']) ...[
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color:
                                  widget.isDark ? Colors.white : Colors.black,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color:
                                    widget.isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              size: 18,
                              color: Colors.red[400],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (RBAC.hasPermission(
                        userRef,
                        Permissions.moderator[ModeratorPermissionsEnum
                            .hideTeacherReview.name]!)) ...[
                      const PopupMenuItem(
                        value: 'hide',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_off_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Hide'),
                          ],
                        ),
                      ),
                    ]
                  ],
                  onSelected: (value) {
                    if (value == 'delete') _handleDelete();
                    if (value == 'edit') _handleEdit(comment);
                    if (value == 'hide') _handleHide();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: ReplyBox(
              parentId: comment['_id'],
              teacherId: widget.teacherId,
              isDark: widget.isDark,
              isReplyToReply: false,
              onReplyAdded: widget.onReplyAdded,
              onReplyRemoved: widget.onReplyRemoved,
            ),
          ),
        ],
      ),
    );
  }
}
