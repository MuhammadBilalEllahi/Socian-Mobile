import 'package:socian/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:socian/utils/date_formatter.dart';
import 'reaction_button.dart';

class ReplyReplyItem extends StatefulWidget {
  final Map<String, dynamic> reply;
  final bool isDark;
  final String teacherId;
  final Function(String, String) onReaction;
  final Function(Map<String, dynamic>, String, bool) onReplyAdded;
  final Function(String, String, bool) onReplyRemoved;

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
  });

  @override
  State<ReplyReplyItem> createState() => _ReplyReplyItemState();
}

class _ReplyReplyItemState extends State<ReplyReplyItem> {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.reply['user'] ?? {};
    final name = user['name'] ?? '[deleted]';
    final isDeleted = user['_id'] == null;

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
                            child: Text(
                              user['name'] != null
                                  ? user['name'][0].toUpperCase()
                                  : '#',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    widget.isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  name,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDeleted
                                        ? theme.colorScheme.onSurface
                                            .withOpacity(0.5)
                                        : null,
                                  ),
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
                          debugPrint(
                              'replyTo: $_replyTo ${widget.reply['user']['name']}');
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
