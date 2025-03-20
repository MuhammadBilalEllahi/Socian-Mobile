import 'package:flutter/material.dart';

class CommentsBottomSheet extends StatelessWidget {
  final String postId;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF09090B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE5E5E5);
    final inputBackgroundColor = isDark ? const Color(0xFF18181B) : Colors.white;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: textColor.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          Divider(
            height: 1,
            thickness: 1,
            color: borderColor,
          ),
          
          // Comments list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 0, // TODO: Replace with actual comments count
              itemBuilder: (context, index) {
                return const SizedBox(); // TODO: Replace with CommentItem widget
              },
            ),
          ),
          
          // Comment input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBackgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: borderColor,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                          color: textColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: textColor,
                      size: 16,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: Implement comment submission
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}