// features
// 1. show feedbacks from student
// 2. show teacher self info
// 3. comment to a feedback
// 4. teacher message to all students
// content upload by teacher like pdf, links, books url or pdf for students

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'dart:developer' as developer;

class TeacherSelfReview extends ConsumerStatefulWidget {
  const TeacherSelfReview({super.key});

  @override
  ConsumerState<TeacherSelfReview> createState() => _TeacherSelfReviewState();
}

class _TeacherSelfReviewState extends ConsumerState<TeacherSelfReview> {
  bool _isLoading = true;
  Map<String, dynamic>? _teacherData;
  List<Map<String, dynamic>> _feedbacks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
  }

  Future<void> _fetchTeacherData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final apiClient = ApiClient();
      final response = await apiClient.get(
        '/api/teacher/account/feedbacks',
        queryParameters: {
          'teacherId': user['_id'],
        },
      );

      setState(() {
        _teacherData = response['teacher'];
        _feedbacks =
            List<Map<String, dynamic>>.from(response['feedbacks'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme colors
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final surfaceColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final accentColor = isDark ? Colors.blue[400]! : Colors.blue[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Teacher Reviews',
          style: theme.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: mutedTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchTeacherData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Teacher Profile Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundImage:
                                        _teacherData?['imageUrl'] != null
                                            ? NetworkImage(
                                                _teacherData!['imageUrl'])
                                            : null,
                                    child: _teacherData?['imageUrl'] == null
                                        ? Icon(
                                            Icons.person,
                                            size: 32,
                                            color: mutedTextColor,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _teacherData?['name'] ?? 'N/A',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _teacherData?['department']
                                                  ?['name'] ??
                                              'N/A',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: mutedTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          (_teacherData?['rating']
                                                  ?.toString() ??
                                              '0.0'),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Feedbacks Section
                        Text(
                          'Student Feedbacks',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_feedbacks.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.feedback_outlined,
                                    size: 48,
                                    color: mutedTextColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No feedbacks yet',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Student feedbacks will appear here',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: mutedTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _feedbacks.length,
                            itemBuilder: (context, index) {
                              final feedback = _feedbacks[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          feedback['user']?['name'] ??
                                              'Anonymous',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Row(
                                          children:
                                              List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex <
                                                      (feedback['rating'] ?? 0)
                                                  ? Icons.star_rounded
                                                  : Icons.star_outline_rounded,
                                              size: 16,
                                              color: starIndex <
                                                      (feedback['rating'] ?? 0)
                                                  ? const Color(0xFFFFD700)
                                                  : mutedTextColor,
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      feedback['feedback'] ?? '',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      feedback['updatedAt'] != null
                                          ? _formatDate(feedback['updatedAt'])
                                          : '',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: mutedTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
