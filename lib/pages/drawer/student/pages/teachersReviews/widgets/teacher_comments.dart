import 'dart:async';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'gif_picker.dart';

class TeacherComments extends StatefulWidget {
  final List<Map<String, dynamic>> comments;
  final String teacherId;

  const TeacherComments({
    super.key,
    required this.comments,
    required this.teacherId,
  });

  @override
  State<TeacherComments> createState() => _TeacherCommentsState();
}

class _TeacherCommentsState extends State<TeacherComments> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment(WidgetRef ref) async {
    if (_commentController.text.trim().isEmpty || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both a rating and a comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ApiClient apiClient = ApiClient();
      await apiClient.post(
        '/api/teacher/rate',
        {
          'teacherId': widget.teacherId,
          'userId': user['_id'],
          'rating': _rating,
          'feedback': _commentController.text.trim(),
          'hideUser': _isAnonymous,
        },
      );

      // Clear form and show success message
      _commentController.clear();
      setState(() {
        _rating = 0;
        _isAnonymous = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment posted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Comments',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Comment Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                // Rating Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate your experience',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = starValue;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                _rating >= starValue 
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 32,
                                color: _rating >= starValue
                                    ? const Color(0xFFFFD700)
                                    : isDark 
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.black.withOpacity(0.3),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                // Comment TextField
                TextField(
                  controller: _commentController,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                // Anonymous Checkbox
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isAnonymous = !_isAnonymous;
                          });
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _isAnonymous
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
                              width: 1.5,
                            ),
                            color: _isAnonymous
                                ? (isDark ? Colors.white : Colors.black)
                                : Colors.transparent,
                          ),
                          child: _isAnonymous
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: isDark ? Colors.black : Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Comment anonymously',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Submit Button Container
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Be respectful in comments',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          return TextButton(
                            onPressed: _isSubmitting 
                              ? null 
                              : () => _submitComment(ref),
                            style: TextButton.styleFrom(
                              backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? Colors.white : Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Comment',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Comments List
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            border: Border.symmetric(
              horizontal: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < widget.comments.length; i++) ...[
                _CommentItem(
                  comment: widget.comments[i],
                  isDark: isDark,
                  teacherId: widget.teacherId,
                ),
                if (i < widget.comments.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final bool isDark;
  final String teacherId;

  const _CommentItem({
    required this.comment,
    required this.isDark,
    required this.teacherId,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _showReplyBox = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                    child: Text(
                      widget.comment['author'][0].toUpperCase(),
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
                                  widget.comment['author'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (widget.comment['isVerified'] == true) ...[
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
                            if (widget.comment['rating'] != null)
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < (widget.comment['rating'] as int)
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    size: 16,
                                    color: index < (widget.comment['rating'] as int)
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
                          widget.comment['date'],
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
                  widget.comment['text'],
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Row(
                  children: [
                    _VoteButton(
                      icon: Icons.arrow_upward_rounded,
                      count: widget.comment['upvotes'] ?? 0,
                      isDark: widget.isDark,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    _VoteButton(
                      icon: Icons.arrow_downward_rounded,
                      count: widget.comment['downvotes'] ?? 0,
                      isDark: widget.isDark,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showReplyBox = !_showReplyBox;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: widget.isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(
                        Icons.reply_rounded,
                        size: 20,
                      ),
                      label: Text(
                        'Reply',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showReplyBox) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: _ReplyBox(
                    isDark: widget.isDark,
                    onSubmit: () {
                      setState(() {
                        _showReplyBox = false;
                      });
                    },
                    teacherId: widget.teacherId,
                    parentId: widget.comment['_id'],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.comment['replies'] != null && (widget.comment['replies'] as List).isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Column(
              children: [
                for (var reply in widget.comment['replies'])
                  _ReplyItem(
                    reply: reply,
                    isDark: widget.isDark,
                    teacherId: widget.teacherId,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReplyItem extends StatefulWidget {
  final Map<String, dynamic> reply;
  final bool isDark;
  final String teacherId;

  const _ReplyItem({
    required this.reply,
    required this.isDark,
    required this.teacherId,
  });

  @override
  State<_ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<_ReplyItem> {
  bool _showReplyBox = false;
  bool _showReactionPicker = false;
  Map<String, dynamic>? _selectedReaction;

  final List<Map<String, dynamic>> _reactions = [
    {'emoji': '😄', 'type': 'haha'},
    {'emoji': '😢', 'type': 'sad'},
    {'emoji': '❤️', 'type': 'love'},
    {'emoji': '😠', 'type': 'angry'},
    {'emoji': '💡', 'type': 'insightful'},
  ];

  @override
  void initState() {
    super.initState();
    // Find if user has already reacted
    final reactions = widget.reply['reactions'] as Map<String, dynamic>?;
    if (reactions != null) {
      for (final reaction in _reactions) {
        if (reactions[reaction['type']] != null) {
          _selectedReaction = reaction;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    widget.reply['author'][0].toUpperCase(),
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
                        widget.reply['author'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.reply['isVerified'] == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        widget.reply['date'],
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
              widget.reply['text'],
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // Reaction Buttons
            Row(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    // Show selected reaction if exists
                    if (_selectedReaction != null)
                      _ReactionButton(
                        emoji: _selectedReaction!['emoji'] as String,
                        count: 1,
                        isDark: widget.isDark,
                        isSelected: true,
                        onPressed: () {
                          setState(() {
                            _selectedReaction = null;
                          });
                        },
                      ),
                    // Show existing reactions from others
                    for (final reaction in _reactions)
                      if ((widget.reply['reactions']?[reaction['type']] ?? 0) > 0 &&
                          _selectedReaction?['type'] != reaction['type'])
                        _ReactionButton(
                          emoji: reaction['emoji'] as String,
                          count: widget.reply['reactions']?[reaction['type']] ?? 0,
                          isDark: widget.isDark,
                          isSelected: false,
                          onPressed: () {
                            setState(() {
                              _selectedReaction = reaction;
                            });
                          },
                        ),
                    // Show add reaction button if no reaction selected
                    if (_selectedReaction == null)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showReactionPicker = !_showReactionPicker;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_reaction_outlined,
                            size: 20,
                            color: widget.isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showReplyBox = !_showReplyBox;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: widget.isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.reply_rounded,
                    size: 20,
                  ),
                  label: Text(
                    'Reply',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (_showReactionPicker) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final reaction in _reactions) ...[
                      if (reaction != _reactions.first) const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedReaction = reaction;
                            _showReactionPicker = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reaction['emoji'] as String,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (_showReplyBox) ...[
              const SizedBox(height: 12),
              _ReplyBox(
                isDark: widget.isDark,
                onSubmit: () {
                  setState(() {
                    _showReplyBox = false;
                  });
                },
                teacherId: widget.teacherId,
                parentId: widget.reply['_id'],
                isReplyToReply: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReplyBox extends StatefulWidget {
  final bool isDark;
  final VoidCallback onSubmit;
  final String teacherId;
  final String? parentId;
  final bool isReplyToReply;

  const _ReplyBox({
    required this.isDark,
    required this.onSubmit,
    required this.teacherId,
    required this.parentId,
    this.isReplyToReply = false,
  });

  @override
  State<_ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<_ReplyBox> {
  final TextEditingController _replyController = TextEditingController();
  String? _selectedGifUrl;
  bool _showGifPicker = false;
  bool _showMentionsList = false;
  List<String> _mentions = [];
  List<Map<String, dynamic>> _mentionSuggestions = [];
  bool _isSubmitting = false;

  Future<void> _submitReply(WidgetRef ref) async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final ApiClient apiClient = ApiClient();
      final endpoint = widget.isReplyToReply 
        ? '/api/teacher/reply/reply/feedback'
        : '/api/teacher/reply/feedback';

      final response = await apiClient.post(
        endpoint,
        {
          'teacherId': widget.teacherId,
          widget.isReplyToReply ? 'feedbackCommentId' : 'feedbackReviewId': widget.parentId,
          'feedbackComment': _replyController.text.trim(),
          'gifUrl': _selectedGifUrl ?? '',
          'mentions': _mentions,
        },
      );

      _replyController.clear();
      setState(() {
        _selectedGifUrl = null;
        _mentions = [];
        _isSubmitting = false;
      });
      widget.onSubmit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply posted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post reply: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleTextChange(String value) async {
    final lastWord = value.split(' ').last;
    if (lastWord.startsWith('@') && lastWord.length > 1) {
      final searchQuery = lastWord.substring(1);
      try {
        final ApiClient apiClient = ApiClient();
        final response = await apiClient.get(
          ApiConstants.searchUsers,
          queryParameters: {'q': searchQuery},
        );

        setState(() {
          _mentionSuggestions = List<Map<String, dynamic>>.from(response['users']);
          _showMentionsList = true;
        });
      } catch (e) {
        print('Error searching users: $e');
      }
    } else {
      setState(() {
        _showMentionsList = false;
      });
    }
  }

  void _handleMentionSelected(Map<String, dynamic> user) {
    final text = _replyController.text;
    final lastAtIndex = text.lastIndexOf('@');
    if (lastAtIndex != -1) {
      final newText = '${text.substring(0, lastAtIndex)}@${user['username']} ';
      _replyController.text = newText;
      _replyController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }
    setState(() {
      _mentions.add(user['_id']);
      _showMentionsList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          if (_selectedGifUrl != null) ...[
            Stack(
              children: [
                Image.network(
                  _selectedGifUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedGifUrl = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showGifPicker = !_showGifPicker;
                  });
                },
                icon: const Icon(Icons.gif_box_outlined),
                color: widget.isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
              ),
              Expanded(
                child: TextField(
                  controller: _replyController,
                  onChanged: _handleTextChange,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Write a reply... Use @ to mention',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return TextButton(
                    onPressed: _isSubmitting ? null : () => _submitReply(ref),
                    style: TextButton.styleFrom(
                      backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(11),
                          bottomRight: Radius.circular(11),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isDark ? Colors.white : Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Reply',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.isDark ? Colors.white : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  );
                },
              ),
            ],
          ),
          if (_showGifPicker)
            Container(
              height: 300,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: GifPicker(
                isDark: widget.isDark,
                onGifSelected: (gifUrl) {
                  setState(() {
                    _selectedGifUrl = gifUrl;
                    _showGifPicker = false;
                  });
                },
              ),
            ),
          if (_showMentionsList)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _mentionSuggestions.length,
                itemBuilder: (context, index) {
                  final user = _mentionSuggestions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: widget.isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      child: Text(
                        user['name'][0].toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    title: Text(
                      user['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '@${user['username']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    onTap: () => _handleMentionSelected(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isDark;
  final VoidCallback onPressed;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final int count;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ReactionButton({
    required this.emoji,
    required this.count,
    required this.isDark,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1))
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 