
import 'package:flutter/material.dart';

// Define the MessageCard as a StatefulWidget
class MessageCard extends StatefulWidget {
  // Define the parameters required by the widget
  final String picture; // URL or asset path for the picture
  final String name;    // Sender's name
  final String message; // The message content
  final String time;     // Time the message was sent

  // Constructor to initialize the parameters
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
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0), // Simplified border radius
        child: Container(
          height: 65,
          color: Colors.teal[200], // You can customize the color or make it dynamic
          padding: const EdgeInsets.all(5), // Add padding inside the container
          child: Row(

            children: [
              // Display the picture
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(widget.picture),
              ),
              const SizedBox(width: 10), // Spacing between picture and text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the name and time in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2), // Spacing between name/time and message
                  // Display the message
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}
