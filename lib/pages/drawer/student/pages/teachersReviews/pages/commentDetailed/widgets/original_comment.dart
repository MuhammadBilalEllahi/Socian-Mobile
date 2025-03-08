import 'package:flutter/material.dart';
import 'package:beyondtheclass/utils/date_formatter.dart';
import 'vote_button.dart';
import 'reply_box.dart';

class OriginalComment extends StatelessWidget {
  final Map<String, dynamic> comment;
  final String teacherId;
  final bool isDark;
  final Function(String, bool) onVote;
  final Function(Map<String, dynamic>, String, bool) onReplyAdded;
  final Function(String, String, bool) onReplyRemoved;

  const OriginalComment({
    super.key,
    required this.comment,
    required this.teacherId,
    required this.isDark,
    required this.onVote,
    required this.onReplyAdded,
    required this.onReplyRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = comment['user'];
    final name = user['name'] ?? 'Anonymous';
    final isDeleted = user['_id'] == null;
    final isAnonymous = comment['isAnonymous'] ?? false;

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
                backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                child: Text(
                  name[0].toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
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
                                color: isDeleted ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                              ),
                            ),
                            if (!isDeleted && !isAnonymous && user['isVerified'] == true) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: Colors.blue,
                              ),
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
                                    : isDark 
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
                  count: comment['upvoteCount'] ?? 0,
                  isDark: isDark,
                  onPressed: () => onVote(comment['_id'], true),
                ),
                const SizedBox(width: 16),
                VoteButton(
                  icon: Icons.arrow_downward_rounded,
                  count: comment['downvoteCount'] ?? 0,
                  isDark: isDark,
                  onPressed: () => onVote(comment['_id'], false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: ReplyBox(
              parentId: comment['_id'],
              teacherId: teacherId,
              isDark: isDark,
              isReplyToReply: false,
              onReplyAdded: onReplyAdded,
              onReplyRemoved: onReplyRemoved,
            ),
          ),
        ],
      ),
    );
  }
} 