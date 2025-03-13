import 'package:flutter/material.dart';
import 'widgets/teacher_avatar.dart';
import 'widgets/teacher_header.dart';
import 'widgets/teacher_contact.dart';
import 'widgets/teacher_feedback.dart';
import 'widgets/teacher_subjects.dart';
import 'widgets/teacher_comments.dart';

class TeacherDetailsPage extends StatelessWidget {
  final Map<String, dynamic> teacher;

  const TeacherDetailsPage({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sample comments data - Replace with actual data from your backend
    final List<Map<String, dynamic>> comments = [
      {
        'author': 'John Doe',
        'date': '2 days ago',
        'text': 'Great teacher! Really helped me understand the concepts.',
        'rating': 5,
        'upvotes': 12,
        'downvotes': 1,
        'isVerified': true,
        'isAnonymous': false,
        'replies': [
          {
            'author': 'Anonymous',
            'date': '1 day ago',
            'text': 'Totally agree! The way they explain complex topics is amazing.',
            'isVerified': false,
            'isAnonymous': true,
            'reactions': {'haha': 2, 'love': 5, 'insightful': 3}
          }
        ]
      },
      {
        'author': 'Anonymous',
        'date': '1 week ago',
        'text': 'Very patient and explains things clearly. Would recommend!',
        'rating': 4,
        'upvotes': 8,
        'downvotes': 0,
        'isVerified': false,
        'isAnonymous': true,
        'replies': [
          {
            'author': 'Mike Johnson',
            'date': '6 days ago',
            'text': 'Yes, they take time to ensure everyone understands.',
            'isVerified': true,
            'isAnonymous': false,
            'reactions': {'love': 3, 'insightful': 2}
          },
          {
            'author': 'Anonymous',
            'date': '5 days ago',
            'text': 'The best teacher in the department!',
            'isVerified': false,
            'isAnonymous': true,
            'reactions': {'haha': 1, 'love': 4, 'insightful': 1}
          }
        ]
      },
    ];

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
              TeacherFeedback(feedback: (teacher['feedbackSummary'] as List).last),
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
              teacherId: teacher['_id'],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        backgroundColor: isDark ? Colors.tealAccent : Colors.teal,
        child: const Icon(Icons.add_comment, color: Colors.white),
        tooltip: 'Add Feedback',
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners for a modern look
        ),
      ),
    );
  }
}
