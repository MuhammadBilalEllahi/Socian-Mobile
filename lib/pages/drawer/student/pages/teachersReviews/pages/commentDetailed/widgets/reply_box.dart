import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import '../../../widgets/gif_picker.dart';

class ReplyBox extends ConsumerStatefulWidget {
  final String parentId;
  final String teacherId;
  final bool isDark;
  final bool isReplyToReply;
  final Function(Map<String, dynamic>, String, bool) onReplyAdded;
  final Function(String, String, bool) onReplyRemoved;
  final String? replyTo;
  final bool isReplyToReplyToReply;
  const ReplyBox({
    super.key,
    required this.parentId,
    required this.teacherId,
    required this.isDark,
    required this.isReplyToReply,
    required this.onReplyAdded,
    required this.onReplyRemoved, 
    this.replyTo,   this.isReplyToReplyToReply =false,
  });

  @override
  ConsumerState<ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends ConsumerState<ReplyBox> {
  final TextEditingController _replyController = TextEditingController();
  final ValueNotifier<bool> _showGifPicker = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _selectedGifUrl = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _replyController.dispose();
    _showGifPicker.dispose();
    _selectedGifUrl.dispose();
    super.dispose();
  }

  Future<void> _handleReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final tempId = DateTime.now().toIso8601String();
    try {
      final userMap = ref.read(authProvider).user;
      if (userMap == null) {
        throw Exception('User not authenticated');
      }

      // Create optimistic reply
      final optimisticReply = {
        '_id': tempId,
        'comment': text,
        'gifUrl': _selectedGifUrl.value,
        'user': {
          '_id': userMap['_id'],
          'name': userMap['name'],
          'isVerified': userMap['isVerified'],
        },
        'isAnonymous': false,
        'createdAt': DateTime.now().toIso8601String(),
        'reactions': {},
      };

      // Add reply optimistically
      widget.onReplyAdded(optimisticReply, widget.parentId, widget.isReplyToReply);

      

      final ApiClient apiClient = ApiClient();
      final endpoint = widget.isReplyToReply
        ? '/api/teacher/reply/reply/feedback'
        : '/api/teacher/reply/feedback';

      await apiClient.post(
        endpoint,
        {
          'teacherId': widget.teacherId,
          widget.isReplyToReply ? 'feedbackCommentId' : 'feedbackReviewId': widget.parentId,
          'feedbackComment': text,
          'gifUrl': _selectedGifUrl.value ?? '',
          if (widget.isReplyToReply && widget.isReplyToReplyToReply && widget.replyTo != null) 'replyTo': widget.replyTo,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply posted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Remove optimistic reply on error
      widget.onReplyRemoved(tempId, widget.parentId, widget.isReplyToReply);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post reply: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }finally{
      // Clear input
      _replyController.clear();
      _selectedGifUrl.value = null;
      _showGifPicker.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: _selectedGifUrl,
            builder: (context, gifUrl, _) {
              if (gifUrl == null) return const SizedBox.shrink();
              return Stack(
                children: [
                  Image.network(
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
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => _selectedGifUrl.value = null,
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _showGifPicker.value = !_showGifPicker.value,
                icon: const Icon(Icons.gif_box_outlined),
                color: widget.isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
              ),
              Expanded(
                child: TextField(
                  controller: _replyController,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              TextButton(
                onPressed: _handleReply,
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
                child: Text(
                  'Reply',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.isDark ? Colors.white : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showGifPicker,
            builder: (context, show, _) {
              if (!show) return const SizedBox.shrink();
              return Container(
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
                    debugPrint("gifUrl--------------------------------: $gifUrl");
                    _selectedGifUrl.value = gifUrl;
                    debugPrint("gifUrl value--------------------------------: ${_selectedGifUrl.value}");
                    _showGifPicker.value = false;
                  },
                ),
              );
            },
          ),
        ],
    );
  }
} 