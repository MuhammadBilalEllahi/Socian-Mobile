import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:socian/pages/drawer/student/pages/teachersReviews/widgets/AddFeedBackSheet.dart';

import 'widgets/TeacherMainPageComments.dart';
import 'widgets/teacher_contact.dart';
import 'widgets/teacher_feedback.dart';
import 'widgets/teacher_header.dart';
import 'widgets/teacher_subjects.dart';

class TeacherDetailsPage extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherDetailsPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    log("TEACHER DETAILS $teacher");
    final GlobalKey<TeacherMainPageCommentsState> commentsKey = GlobalKey();
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
            TeacherMainPageComments(
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
                child: AddFeedBackSheet(
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
          tooltip: 'Add Feedback',
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_comment, color: Colors.white),
        ),
      ),
    );
  }
}
