import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  final String picture; // URL or asset path for the picture
  final String name;    // Sender's name
  final String message; // The message content
  final String time;    // Time the message was sent

  const MessageCard({
    Key? key,
    required this.picture,
    required this.name,
    required this.message,
    required this.time,
  }) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade900, Colors.tealAccent.shade400
            ],
            // colors: [
            //   Colors.blue.shade700,
            //   Colors.purple.shade300
            // ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(4, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(widget.picture),
            ),
            const SizedBox(width: 12), // Space between avatar and text

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // Space between name/time and message

                  // Message Content
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.3, // Line height for better readability
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
