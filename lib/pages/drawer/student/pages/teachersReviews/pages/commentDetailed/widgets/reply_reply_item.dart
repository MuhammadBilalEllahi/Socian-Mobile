import 'package:beyondtheclass/pages/drawer/student/pages/teachersReviews/pages/commentDetailed/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/utils/date_formatter.dart';
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
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
                     name,
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
                         name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDeleted ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                        ),
                      ),
                      if (!isDeleted &&  user['isVerified'] == true) ...[
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
            Row(
              children: [
                if (widget.reply['replyTo'] != null) ...[
                  Text('@${widget.reply['replyTo']['name']} ', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue.shade300),),
                ],
                Text(replyText, style: theme.textTheme.bodyMedium,),
                
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
                 
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showReplyBox = !_showReplyBox;
                      _replyTo = widget.reply['user']['_id'];
                      debugPrint('replyTo: $_replyTo ${widget.reply['user']['name']}');
                    });
                  },
                  icon: const Icon(Icons.reply_rounded),
                ),
             
              ],
            ),

            if (_showReplyBox)
              ReplyBox(
                parentId: widget.feedbackCommentId,
                teacherId: widget.teacherId,
                isDark: widget.isDark,
                isReplyToReply: true,
                onReplyAdded: widget.onReplyAdded,
                onReplyRemoved: widget.onReplyRemoved,
                replyTo: _replyTo,
                isReplyToReplyToReply: true,
              ),
          ],
        ),
      ),
    );
  }
} 