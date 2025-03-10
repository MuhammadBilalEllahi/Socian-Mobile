import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  final String picture;
  final String name;   
  final String message;
  final String time;   
  final bool isOnline;

  const MessageCard({
    super.key,
    required this.picture,
    required this.name,
    required this.message,
    required this.time,
    this.isOnline = true,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    // Helper function to determine message type icon
    Widget getMessageTypeIcon() {
      if (widget.message.contains('sent a GIF')) {
        return Icon(Icons.gif_box_outlined, size: 18, color: mutedForeground);
      } else if (widget.message.contains('sent an image')) {
        return Icon(Icons.image_outlined, size: 18, color: mutedForeground);
      } else if (widget.message.contains('sent a voice message')) {
        return Icon(Icons.mic_outlined, size: 18, color: mutedForeground);
      } else {
        return Icon(Icons.done_all, size: 18, color: Theme.of(context).primaryColor);
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            // Handle message tap
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Profile Picture with Story Ring
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isOnline ? const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ) : null,
                    border: widget.isOnline ? null : Border.all(color: border, width: 1),
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(1),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(widget.picture),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Message Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          getMessageTypeIcon(),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: mutedForeground,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            " • ",
                            style: TextStyle(
                              color: mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.time,
                            style: TextStyle(
                              color: mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: border),
      ],
    );
  }
}
