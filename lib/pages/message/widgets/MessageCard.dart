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
    // Helper function to determine message type icon
    Widget getMessageTypeIcon() {
      if (widget.message.contains('sent a GIF')) {
        return const Icon(Icons.gif_box_outlined, size: 18, color: Colors.grey);
      } else if (widget.message.contains('sent an image')) {
        return const Icon(Icons.image_outlined, size: 18, color: Colors.grey);
      } else if (widget.message.contains('sent a voice message')) {
        return const Icon(Icons.mic_outlined, size: 18, color: Colors.grey);
      } else {
        return const Icon(Icons.done_all, size: 18, color: Colors.blue);
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
                      colors: [Colors.purple, Colors.black],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ) : null,
                  ),
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          getMessageTypeIcon(), // Now returns Widget instead of Widget?
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text(" • "),
                          Text(
                            widget.time,
                            style: TextStyle(
                              color: Colors.grey[600],
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
        const Divider(height: 1),
      ],
    );
  }
}
