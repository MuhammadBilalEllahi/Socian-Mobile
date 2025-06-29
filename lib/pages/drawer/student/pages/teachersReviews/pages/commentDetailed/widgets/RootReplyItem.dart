import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/components/widgets/my_snackbar.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/EditReplyBox.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/ReplyReplyItem.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/index.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/shared/utils/date_formatter.dart';
import 'package:socian/shared/utils/rbac.dart';

class RootReplyItem extends ConsumerStatefulWidget {
  final Map<String, dynamic> reply;
  final bool isDark;
  final String teacherId;
  final Function(String, String) onReaction;
  final Function(Map<String, dynamic>, String, bool) onReplyAdded;
  final Function(String, String, bool) onReplyRemoved;
  final Function(Map<String, dynamic>, String, bool) onReplyEdited;
  const RootReplyItem({
    super.key,
    required this.reply,
    required this.isDark,
    required this.teacherId,
    required this.onReaction,
    required this.onReplyAdded,
    required this.onReplyRemoved,
    required this.onReplyEdited,
  });

  @override
  ConsumerState<RootReplyItem> createState() => _RootReplyItemState();
}

class _RootReplyItemState extends ConsumerState<RootReplyItem> {
  bool _showReplyBox = false;
  bool _showReplyReplies = false;
  final apiClient = ApiClient();
  List<Map<String, dynamic>> _replyReplies = [];
  bool _isLoadingReplies = false;

  Future<void> _loadReplyReplies() async {
    if (_isLoadingReplies) return;

    setState(() {
      _isLoadingReplies = true;
    });

    try {
      final response = await apiClient.get(
          '/api/teacher/reply/reply/feedback?feedbackCommentId=${widget.reply['_id']}');
      // debugPrint('response reply replies: $response');
      final data = response['replies']['replies'] as List;
      // debugPrint('data reply replies: $data');
      final mappedReplies =
          data.map((reply) => Map<String, dynamic>.from(reply as Map)).toList();
      // debugPrint('mappedReplies: $mappedReplies');
      setState(() {
        _replyReplies = mappedReplies;
      });
    } catch (e) {
      // debugPrint('Error loading reply replies: $e');
    } finally {
      setState(() {
        _isLoadingReplies = false;
      });
    }
  }

  void _handleReplyAdded(
      Map<String, dynamic> reply, String parentId, bool isReplyToReply) {
    final userMap = ref.read(authProvider).user;
    if (userMap == null) return;

    // If the reply already has a server-generated ID, update the existing reply
    if (reply['_id'] != null && !reply['_id'].toString().contains('T')) {
      setState(() {
        // Find the temporary reply by checking if the ID contains a timestamp format
        final index = _replyReplies.indexWhere((r) =>
            r['_id'] != null &&
            r['_id'].toString().contains('T') &&
            r['comment'] == reply['comment']);

        if (index != -1) {
          // Replace the temporary reply with the server response
          _replyReplies[index] = reply;
        } else {
          // If no temporary reply found, add the new reply
          _replyReplies = [..._replyReplies, reply];
        }
      });
      return;
    }

    // Otherwise, create an optimistic reply
    final tempId = DateTime.now().toIso8601String();
    final optimisticReply = Map<String, dynamic>.from({
      '_id': tempId,
      'comment': reply['comment'],
      'gifUrl': reply['gifUrl'],
      'user': Map<String, dynamic>.from({
        '_id': userMap['_id'],
        'username': userMap['username'],
        'name': userMap['name'],
        'isVerified': userMap['isVerified'],
      }),
      'profile': {
        'picture': userMap['profile']?['picture'] ?? '',
      },
      'isAnonymous': false,
      'createdAt': DateTime.now().toIso8601String(),
      'reactions': <String, dynamic>{},
    });

    setState(() {
      _replyReplies = [..._replyReplies, optimisticReply];
    });

    widget.onReplyAdded(optimisticReply, parentId, isReplyToReply);
  }

  Future<void> _handleDelete() async {
    // TODO: Implement delete logic

    try {
      final response = await apiClient.delete(
          '/api/teacher/reply/feedback/delete?feedbackReviewId=${widget.reply['_id']}');
      if (response.isNotEmpty) {
        showSnackbar(context, response['message'], isError: false);
        widget.onReplyRemoved(widget.reply['_id'], widget.reply['_id'], false);
      }
    } catch (e) {
      showSnackbar(context, e.toString(), isError: true);
    }
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
            ));
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
      final response = await apiClient.put(
        '/api/mod/teacher/reply/feedback/hide?feedbackReviewId=${widget.reply['_id']}',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.reply['user'] ?? {};
    final name = user['name'] ?? '[deleted]';
    final username = user['username'] ?? '[deleted]';
    final picture = user?['profile']?['picture'] ?? '';
    final userRef = ref.read(authProvider).user;
    final isDeleted = user['_id'] == null;
    final isAnonymous = widget.reply['isAnonymous'] ?? false;
    final date = widget.reply['updatedAt'] ?? widget.reply['createdAt'] ?? '';
    final replyText = widget.reply['comment'] ?? widget.reply['text'] ?? '';
    final gifUrl = widget.reply['gifUrl'] ?? '';
    final reactions =
        Map<String, dynamic>.from(widget.reply['reactions'] as Map? ?? {});
    final isTemporary = widget.reply['_id'] != null &&
        widget.reply['_id'].toString().contains('T');

    print("WidgetReply ${widget.reply}");
    return Opacity(
      opacity: isTemporary ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
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
                            child: (!isAnonymous && picture.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      picture,
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Text(
                                        (isAnonymous
                                                ? 'A'
                                                : user['name'] != null
                                                    ? user['name'][0]
                                                    : '#')
                                            .toUpperCase(),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: widget.isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    (isAnonymous
                                            ? 'A'
                                            : user['name'] != null
                                                ? user['name'][0]
                                                : '#')
                                        .toUpperCase(),
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
                                      isAnonymous ? 'Anonymous' : name,
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
                                      isAnonymous ? '@anonymous' : '@$username',
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
                                    !isAnonymous &&
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        replyText,
                        style: theme.textTheme.bodyMedium,
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
                  Wrap(spacing: -10, children: [
                    if (widget.reply['replies'] != null &&
                        widget.reply['replies'].length > 0)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showReplyReplies = !_showReplyReplies;
                            if (_showReplyReplies) {
                              _loadReplyReplies();
                            }
                          });
                        },
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          iconSize: 20,
                        ),
                        icon: Icon(_showReplyReplies
                            ? Icons.remove_rounded
                            : Icons.add_rounded),
                      ),
                    if (!isDeleted)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showReplyBox = !_showReplyBox;
                          });
                        },
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          iconSize: 20,
                        ),
                        icon: const Icon(Icons.reply_rounded),
                      ),
                  ])
                ],
              ),
              const SizedBox(height: 8),
              if (_showReplyBox && !isDeleted)
                ReplyBox(
                  parentId: widget.reply['_id'],
                  teacherId: widget.teacherId,
                  isDark: widget.isDark,
                  isReplyToReply: true,
                  onReplyAdded: _handleReplyAdded,
                  onReplyRemoved: widget.onReplyRemoved,
                ),
              if (_showReplyReplies && _isLoadingReplies)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_showReplyReplies)
                ..._replyReplies.map((reply) => ReplyReplyItem(
                      feedbackCommentId: widget.reply['_id'],
                      reply: Map<String, dynamic>.from(reply),
                      isDark: widget.isDark,
                      teacherId: widget.teacherId,
                      onReaction: widget.onReaction,
                      onReplyAdded: widget.onReplyAdded,
                      onReplyRemoved: widget.onReplyRemoved,
                      parentUsername: widget.reply['user']?['name'] ?? '',
                      onReplyEdited: (reply, parentId, isReplyToReply) {
                        // widget.onReplyEdited
                        //     .call(reply, parentId, isReplyToReply);
                        setState(() {
                          _replyReplies
                              .removeWhere((r) => r['_id'] == reply['_id']);
                          _replyReplies.add(reply);
                        });
                      },
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
