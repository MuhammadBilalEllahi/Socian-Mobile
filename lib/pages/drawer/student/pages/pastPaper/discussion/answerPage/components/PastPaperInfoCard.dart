import 'package:flutter/material.dart';

class PastPaperInfoCard extends StatelessWidget {
  final Map<String, dynamic> paper;
  final bool isFirst;
  final bool isLast;
  final Function(String, String, String) onPaperSelected;
  final VoidCallback onChatBoxToggle;

  const PastPaperInfoCard({
    super.key,
    required this.paper,
    required this.isFirst,
    required this.isLast,
    required this.onPaperSelected,
    required this.onChatBoxToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Custom theme colors
    final background =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final url = paper['file']?['url'];
            final name = paper['name'];
            final year = paper['year'];
            if (url != null && name != null && year != null) {
              onPaperSelected(url, name, year);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Paper Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: foreground,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Paper Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        paper['name'] ?? 'Untitled Paper',
                        style: TextStyle(
                          color: foreground,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 4),
                      Text(
                        'Year: ${paper['year'] ?? 'N/A'}',
                        style: TextStyle(
                          color: mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat Button
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: foreground,
                  ),
                  onPressed: onChatBoxToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
