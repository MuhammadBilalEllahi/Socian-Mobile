import 'dart:developer';

import 'package:flutter/material.dart';
import 'widgets/teacher_avatar.dart';
import 'widgets/teacher_header.dart';
import 'widgets/teacher_contact.dart';
import 'widgets/teacher_feedback.dart';
import 'widgets/teacher_subjects.dart';
import 'widgets/teacher_comments.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/shared/services/api_client.dart';

class TeacherDetailsPage extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherDetailsPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    log("TEACHER DETAILS ${teacher}");
    final GlobalKey<TeacherCommentsState> commentsKey = GlobalKey();
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Teacher Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TeacherHeader(teacher: teacher),
            const SizedBox(height: 24),
            TeacherContact(email: teacher['email'] ?? 'N/A'),
            const SizedBox(height: 16),
            if (teacher['feedbackSummary'] != null &&
                (teacher['feedbackSummary'] as List).isNotEmpty) ...[
              TeacherFeedback(
                feedback:
                    (teacher['feedbackSummary'] as List).last['summary'] ?? '',
              ),
              const SizedBox(height: 24),
            ],
            if (teacher['subjectsTaught'] != null &&
                (teacher['subjectsTaught'] as List).isNotEmpty) ...[
              TeacherSubjects(
                subjects: List<String>.from(teacher['subjectsTaught']),
              ),
              const SizedBox(height: 24),
            ],
            TeacherComments(
              key: commentsKey,
              teacherId: teacher['_id'],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
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
                child: _CreateTeacherCommentSheet(
                  teacherId: teacher['_id'],
                  onOptimisticComment: (optimisticComment,
                      {required Future<bool> Function() confirm}) {
                    commentsKey.currentState?.addOptimisticComment(
                        optimisticComment,
                        confirm: confirm);
                  },
                ),
              ),
            );
          },
          backgroundColor: isDark
              ? const Color.fromARGB(255, 65, 65, 65)
              : const Color.fromARGB(255, 29, 29, 29),
          child: const Icon(Icons.add_comment, color: Colors.white),
          tooltip: 'Add Feedback',
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _CreateTeacherCommentSheet extends ConsumerStatefulWidget {
  final String teacherId;
  final void Function(Map<String, dynamic> optimisticComment,
      {required Future<bool> Function() confirm})? onOptimisticComment;
  const _CreateTeacherCommentSheet(
      {Key? key, required this.teacherId, this.onOptimisticComment})
      : super(key: key);

  @override
  ConsumerState<_CreateTeacherCommentSheet> createState() =>
      _CreateTeacherCommentSheetState();
}

class _CreateTeacherCommentSheetState
    extends ConsumerState<_CreateTeacherCommentSheet> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
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

    final user = ref.read(authProvider).user;
    if (user == null) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User not authenticated'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final optimisticComment = {
      '_id': UniqueKey().toString(),
      'user': user,
      'feedback': _commentController.text.trim(),
      'rating': _rating,
      'isAnonymous': _isAnonymous,
      'updatedAt': DateTime.now().toIso8601String(),
      'optimistic': true,
      'opacity': 0.5,
    };

    Future<bool> confirm() async {
      try {
        final ApiClient apiClient = ApiClient();
        final response = await apiClient.post(
          '/api/teacher/rate',
          {
            'teacherId': widget.teacherId,
            'userId': user['_id'],
            'rating': _rating,
            'feedback': _commentController.text.trim(),
            'hideUser': _isAnonymous,
          },
        );
        return true;
      } catch (e) {
        return false;
      }
    }

    widget.onOptimisticComment?.call(optimisticComment, confirm: confirm);

    _commentController.clear();
    setState(() {
      _rating = 0;
      _isAnonymous = false;
      _isSubmitting = false;
    });
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment posted!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseBg = isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5);
    final cardBg = isDark ? const Color(0xFF232326) : Colors.white;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent = isDark ? Colors.white : Colors.black;
    final muted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    return Container(
      decoration: BoxDecoration(
        color: baseBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Add Feedback',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: accent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Rate your experience',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: muted,
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
                          ? (isDark ? Colors.white : Colors.black)
                          : muted,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 1.2),
              ),
              child: TextField(
                controller: _commentController,
                style: theme.textTheme.bodyLarge?.copyWith(color: accent),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: muted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (val) {
                    setState(() {
                      _isAnonymous = val ?? false;
                    });
                  },
                  activeColor: accent,
                  side: BorderSide(color: border, width: 1.2),
                  checkColor: isDark ? Colors.black : Colors.white,
                ),
                Text(
                  'Comment anonymously',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Be respectful in comments',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Comment',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
