import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/core/utils/rbac.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/EditReplyBox.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/index.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/widgets/my_snackbar.dart';
import 'package:socian/utils/date_formatter.dart';

class ReplyReplyItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> reply;
  final bool isDark;
  final String teacherId;
  final Function(String, String) onReaction;
  final Function(Map<String, dynamic>, String, bool) onReplyAdded;
  final Function(String, String, bool) onReplyRemoved;
  final Function(Map<String, dynamic>, String, bool) onReplyEdited;
  final String? parentUsername;

  final String feedbackCommentId;

  const ReplyReplyItem({
    super.key,
    required this.reply,
    required this.isDark,
    required this.teacherId,
    required this.onReaction,
    required this.onReplyAdded,
    required this.onReplyRemoved,
    required this.feedbackCommentId,
    this.parentUsername,
    required this.onReplyEdited,
  });

  @override
  ConsumerState<ReplyReplyItem> createState() => _ReplyReplyItemState();
}

class _ReplyReplyItemState extends ConsumerState<ReplyReplyItem> {
  bool _showReplyBox = false;
  String _replyTo = '';
  final List<Map<String, dynamic>> _nestedReplies = [];

  void _handleReplyAdded(
      Map<String, dynamic> reply, String parentId, bool isReplyToReply) {
    // If this is a server response with a permanent ID
    if (reply['_id'] != null && !reply['_id'].toString().contains('T')) {
      setState(() {
        // Find and replace the temporary reply in the widget's reply if it matches
        if (widget.reply['_id'].toString().contains('T') &&
            widget.reply['comment'] == reply['comment']) {
          widget.reply.addAll(reply);
        }

        // Also update nested replies if any
        final index = _nestedReplies.indexWhere((r) =>
            r['_id'] != null &&
            r['_id'].toString().contains('T') &&
            r['comment'] == reply['comment']);

        if (index != -1) {
          _nestedReplies[index] = reply;
        } else {
          _nestedReplies.add(reply);
        }
      });
    } else {
      // Add the optimistic reply
      setState(() {
        _nestedReplies.add(reply);
      });
    }

    // Pass the reply up to parent
    widget.onReplyAdded(reply, parentId, isReplyToReply);
    widget.reply['isTemporary'] = false;
  }

  void _handleEdit(Map<String, dynamic> reply) {
    // TODO: Implement edit logic

    showModalBottomSheet(
        enableDrag: true,
        context: context,
        builder: (context) => EditReplyBox(
              reply: reply,
              parentId: widget.reply['_id'],
              teacherId: widget.teacherId,
              isDark: widget.isDark,
              isReplyToReply: false,
              onReplyRemoved: widget.onReplyRemoved,
              onReplyAdded: widget.onReplyAdded,
              onReplyEdited: widget.onReplyEdited,
              isReplyToReplyToReply: true,
            ));
  }

  final _reasonController = TextEditingController();

  Widget _hideReasonDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      title: const Text('Hide Reason Reply\'s reply',
          style: TextStyle(fontSize: 16)),
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
      final response = await apiClient.put(
        '/api/mod/teacher/reply/reply/feedback/hide?feedbackCommentId=${widget.reply['_id']}',
        {
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
    // TODO: Implement delete logic
    final apiClient = ApiClient();
    try {
      final response = await apiClient.delete(
          '/api/teacher/reply/reply/feedback/delete?feedbackCommentId=${widget.reply['_id']}');
      if (response.isNotEmpty) {
        showSnackbar(context, response['message'], isError: false);
        widget.onReplyRemoved(widget.reply['_id'], widget.reply['_id'], false);
      }
    } catch (e) {
      showSnackbar(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRef = ref.read(authProvider).user;
    final theme = Theme.of(context);
    final user = widget.reply['user'] ?? {};
    final name = user['name'] ?? '[deleted]';
    final username = user['username'] ?? '[deleted]';
    final isDeleted = user['_id'] == null;
    final picture = user?['profile']?['picture'] ?? '';
    final date = widget.reply['updatedAt'] ?? widget.reply['createdAt'] ?? '';
    final replyText = widget.reply['comment'] ?? widget.reply['text'] ?? '';
    final gifUrl = widget.reply['gifUrl'] ?? '';
    final reactions = widget.reply['reactions'] as Map<String, dynamic>? ?? {};
    final isTemporary = widget.reply['_id'] != null &&
        widget.reply['_id'].toString().contains('T');

    return Opacity(
      opacity: isTemporary ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: widget.isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            child: (picture.isNotEmpty && picture != null)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      picture,
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    user['name'] != null
                                        ? user['name'][0].toUpperCase()
                                        : '#',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isDeleted
                                            ? theme.colorScheme.onSurface
                                                .withOpacity(0.5)
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '@$username',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        letterSpacing: 0.5,
                                        color: isDeleted
                                            ? theme.colorScheme.onSurface
                                                .withOpacity(0.5)
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                if (!isDeleted &&
                                    user['isVerified'] == true) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ],
                                const Spacer(),
                                if (isTemporary)
                                  const Text(
                                    'Sending...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Text(
                                    DateFormatter.formatDate(date),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ...[
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
                                    color: widget.isDark
                                        ? Colors.grey[900]
                                        : Colors.white,
                                    elevation: 4,
                                    itemBuilder: (context) => [
                                      if (widget.reply['user']?['_id'] ==
                                          userRef?['_id']) ...[
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                size: 18,
                                                color: widget.isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                  color: widget.isDark
                                                      ? Colors.white
                                                      : Colors.black,
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
                                          Permissions.moderator[
                                              ModeratorPermissionsEnum
                                                  .hideFeedBackRootReply
                                                  .name]!)) ...[
                                        const PopupMenuItem(
                                          value: 'hide',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility_off_rounded,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text('Hide'),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                    onSelected: (value) {
                                      if (value == 'delete') _handleDelete();
                                      if (value == 'edit')
                                        _handleEdit(widget.reply);
                                      if (value == 'hide') _handleHide();
                                    },
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (widget.reply['replyTo'] != null) ...[
                            Text(
                              '@${widget.reply['replyTo']['name']} ',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.blue.shade300),
                            ),
                          ],
                          Flexible(
                            child: Text(
                              replyText,
                              style: theme.textTheme.bodyMedium,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isTemporary)
                    Positioned.fill(
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                ],
              ),
              if (gifUrl != null && gifUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    gifUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final reaction in [
                        {'emoji': '😄', 'type': 'haha'},
                        {'emoji': '😢', 'type': 'sad'},
                        {'emoji': '❤️', 'type': 'love'},
                        {'emoji': '😠', 'type': 'angry'},
                        {'emoji': '💡', 'type': 'insightful'},
                      ])
                        ReactionButton(
                          emoji: reaction['emoji'] as String,
                          count: reactions[reaction['type']] ?? 0,
                          isDark: widget.isDark,
                          isSelected: false,
                          onPressed: () => widget.onReaction(
                              widget.reply['_id'], reaction['type'] as String),
                        ),
                    ],
                  ),
                  if (!isDeleted)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showReplyBox = !_showReplyBox;
                          _replyTo = widget.reply['user']['_id'];
                          // debugPrint(  'replyTo: $_replyTo ${widget.reply['user']['name']}');
                        });
                      },
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        iconSize: 20,
                      ),
                      icon: const Icon(Icons.reply_outlined),
                    ),
                ],
              ),
              if (_showReplyBox && !isDeleted)
                ReplyBox(
                  parentId: widget.feedbackCommentId,
                  teacherId: widget.teacherId,
                  isDark: widget.isDark,
                  isReplyToReply: true,
                  onReplyAdded: _handleReplyAdded,
                  onReplyRemoved: widget.onReplyRemoved,
                  replyTo: _replyTo,
                  isReplyToReplyToReply: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
