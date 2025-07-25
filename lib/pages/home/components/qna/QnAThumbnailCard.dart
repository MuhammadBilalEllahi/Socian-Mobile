


import 'package:flutter/material.dart';

class QnAThumbnailCard extends StatefulWidget {
  const QnAThumbnailCard({super.key});

  @override
  State<QnAThumbnailCard> createState() => _QnAThumbnailCardState();
}

class _QnAThumbnailCardState extends State<QnAThumbnailCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 260,
        width: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent.shade400, Colors.teal.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture and name
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage("assets/images/anime.png"),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "John Doe",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Text("CS",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,fontSize: 12),),
                          SizedBox(width: 5,),
                          Icon(Icons.circle,size: 6,color: Colors.white,),
                          SizedBox(width: 5,),
                          Text("10 min ago",style: TextStyle(fontSize: 12,color: Colors.white),
                          )
                        ],
                      ),

                    ],
                  ),
                ],
              ),

              // Answer snippet
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus magna lacus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus magna lacus.",
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),

              // Upvote and downvote row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.arrow_upward, size: 24, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "15",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.arrow_downward, size: 24, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "3",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.reply, size: 24, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "15",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
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

