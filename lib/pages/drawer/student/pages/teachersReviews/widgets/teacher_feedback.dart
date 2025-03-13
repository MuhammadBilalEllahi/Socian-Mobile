
import 'package:flutter/material.dart';

class TeacherFeedback extends StatelessWidget {
  final String feedback;

  const TeacherFeedback({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Feedback Summary',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.6,
              color: isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
              shadows: [
                Shadow(
                  color: isDark ? Colors.tealAccent.withOpacity(0.3) : Colors.teal.withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Feedback Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.grey[850]!.withOpacity(0.9), Colors.grey[900]!.withOpacity(0.95)]
                    : [Colors.white, Colors.grey[100]!.withOpacity(0.9)],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              feedback,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                height: 1.6, // Generous line spacing for readability
                color: isDark ? Colors.grey[200] : Colors.grey[800],
                shadows: [
                  Shadow(
                    color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}