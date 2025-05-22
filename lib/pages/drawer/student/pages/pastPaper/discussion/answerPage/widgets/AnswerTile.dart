import 'package:socian/pages/drawer/student/pages/pastPaper/discussion/answerPage/answerview/AnswerView.dart';
import 'package:flutter/material.dart';

class AnswerTile extends StatelessWidget {
  final Map<String, dynamic> answer;
  final Color foreground;
  final Color answerBackground;
  final Color mutedForeground;

  const AnswerTile({
    super.key,
    required this.answer,
    required this.foreground,
    required this.answerBackground,
    required this.mutedForeground,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("VALEUE ${answer['_id']}");
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AnswerView(
                answerId: answer['_id'],
                content: answer['content'],
                questionId: answer['questionId'])));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: answerBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Answer Content with User Avatar
            RichText(
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(
                          answer['answeredByUser']?['profile']?['picture'] ??
                              'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg',
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    spellOut: true,
                    text: answer['content'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: foreground,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Voting and Comments Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${answer['upvotes']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.image,
                      size: 16,
                      color: mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${answer['upvotes']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedForeground,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${answer['upvotes']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.thumb_down_outlined,
                      size: 16,
                      color: mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${answer['downvotes']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(answer['replies'] as List?)?.length ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
