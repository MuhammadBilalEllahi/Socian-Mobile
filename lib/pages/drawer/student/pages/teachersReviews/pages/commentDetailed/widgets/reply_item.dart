import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/index.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/utils/date_formatter.dart';
import 'reaction_button.dart';
import 'reply_reply_item.dart';

class ReplyItem extends StatefulWidget {
  final Map<String, dynamic> reply;
  final bool isDark;
  final String teacherId;
  final Function(String, String) onReaction;
  final Function(Map<String, dynamic>, String, bool) onReplyAdded;
  final Function(String, String, bool) onReplyRemoved;

  const ReplyItem({
    super.key,
    required this.reply,
    required this.isDark,
    required this.teacherId,
    required this.onReaction,
    required this.onReplyAdded,
    required this.onReplyRemoved,
  });

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
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
      final response = await apiClient.get('/api/teacher/reply/reply/feedback?feedbackCommentId=${widget.reply['_id']}');
      debugPrint('response reply replies: $response');
      final data = response['replies']['replies'] as List;
      debugPrint('data reply replies: $data');
      final mappedReplies = data.map((reply) => reply as Map<String, dynamic>).toList();
      debugPrint('mappedReplies: $mappedReplies');
      setState(() {
        _replyReplies = List<Map<String, dynamic>>.from(mappedReplies);
      });
    } catch (e) {
      debugPrint('Error loading reply replies: $e');
    } finally {
      setState(() {
        _isLoadingReplies = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.reply['user'] ?? {};
    final name = user['name'] ?? '[deleted]';
    final isDeleted = user['_id'] == null;
    final isAnonymous = widget.reply['isAnonymous'] ?? false;
    final date = widget.reply['updatedAt'] ?? widget.reply['createdAt'] ?? '';
    final replyText = widget.reply['comment'] ?? widget.reply['text'] ?? '';
    final gifUrl = widget.reply['gifUrl'] ?? '';
    final reactions = widget.reply['reactions'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  child: Text(
                    (isAnonymous ? 'A' : name[0]).toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        isAnonymous ? 'Anonymous' : name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDeleted ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                        ),
                      ),
                      if (!isDeleted && !isAnonymous && user['isVerified'] == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        DateFormatter.formatDate(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
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
                        onPressed: () => widget.onReaction(widget.reply['_id'], reaction['type'] as String),
                      ),
                  ],
                ),
                
                Wrap(
                  spacing: -10,
                  children: [
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
                  icon: const Icon(Icons.add_rounded),
                ),
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
            
            if (_showReplyBox)
              ReplyBox(
                parentId: widget.reply['_id'],
                teacherId: widget.teacherId,
                isDark: widget.isDark,
                isReplyToReply: true,
                onReplyAdded: widget.onReplyAdded,
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
                reply: reply,
                isDark: widget.isDark,
                teacherId: widget.teacherId,
                onReaction: widget.onReaction,
                onReplyAdded: widget.onReplyAdded,
                onReplyRemoved: widget.onReplyRemoved,
                parentUsername: widget.reply['user']?['name'] ?? '',
              )),
          ],
        ),
      ),
    );
  }
}