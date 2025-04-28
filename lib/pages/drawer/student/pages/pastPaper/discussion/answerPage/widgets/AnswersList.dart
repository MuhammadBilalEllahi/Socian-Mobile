import 'package:flutter/material.dart';
import 'QuestionCard.dart';

class AnswersList extends StatelessWidget {
  final List<Map<String, dynamic>> answers;
  final bool isLoading;
  final Color primaryColor;
  final Color mutedForeground;
  final Color cardBackground;
  final Color border;
  final Color foreground;
  final Color answerBackground;
  final int moreCount;
  final bool showFull;
  final Function(int, bool) onShowMoreToggle;

  const AnswersList({
    super.key,
    required this.answers,
    required this.isLoading,
    required this.primaryColor,
    required this.mutedForeground,
    required this.cardBackground,
    required this.border,
    required this.foreground,
    required this.answerBackground,
    required this.moreCount,
    required this.showFull,
    required this.onShowMoreToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading answers...',
              style: TextStyle(
                color: mutedForeground,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else if (answers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.question_answer_outlined,
              size: 48,
              color: mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'No answers available',
              style: TextStyle(
                color: mutedForeground,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: answers.length,
        itemBuilder: (context, index) {
          final question = answers[index];
          return QuestionCard(
            question: question,
            cardBackground: cardBackground,
            border: border,
            foreground: foreground,
            answerBackground: answerBackground,
            mutedForeground: mutedForeground,
            moreCount: moreCount,
            showFull: showFull,
            onShowMoreToggle: (show) => onShowMoreToggle(index, show),
          );
        },
      );
    }
  }
}
