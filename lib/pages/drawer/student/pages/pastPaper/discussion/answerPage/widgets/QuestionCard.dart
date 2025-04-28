import 'package:flutter/material.dart';
import 'AnswerTile.dart';

class QuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  final Color cardBackground;
  final Color border;
  final Color foreground;
  final Color answerBackground;
  final Color mutedForeground;
  final int moreCount;
  final bool showFull;
  final Function(bool) onShowMoreToggle;

  const QuestionCard({
    super.key,
    required this.question,
    required this.cardBackground,
    required this.border,
    required this.foreground,
    required this.answerBackground,
    required this.mutedForeground,
    required this.moreCount,
    required this.showFull,
    required this.onShowMoreToggle,
  });

  @override
  Widget build(BuildContext context) {
    final answersList = question['answers'] as List? ?? [];
    final showAll = showFull || answersList.length <= moreCount;
    final displayCount = showAll ? answersList.length : moreCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Q${question['questionNumberOrAlphabet']}: ${question['questionContent']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: foreground,
                height: 1.4,
              ),
            ),
          ),
          // Answers
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final answer = answersList[index];
              return AnswerTile(
                answer: answer,
                foreground: foreground,
                answerBackground: answerBackground,
                mutedForeground: mutedForeground,
              );
            },
          ),
          if (answersList.length > moreCount)
            GestureDetector(
              onTap: () => onShowMoreToggle(!showFull),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      " ${showFull ? '-' : '+'} ${answersList.length - moreCount} answers",
                      style: TextStyle(
                        color: mutedForeground,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: mutedForeground,
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
