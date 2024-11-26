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
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),

        child: Container(
          height: 180,
          width: 200,
          color: Colors.tealAccent[400],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              // profile pic
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(mainAxisAlignment:MainAxisAlignment.center, children: [CircleAvatar(radius: 25,backgroundImage: AssetImage("assets/images/anime.png"),)],),
              ),
              // answer
              Row(children: [Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(width:190,child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, aliqua consectetur amet, consectetur .",style: TextStyle(fontStyle: FontStyle.italic),)),
              )],),
              // upvote and downvote
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward),
                  Text("15"),
                  Icon(Icons.arrow_downward),
                  Text("3")

              ],),
            ],
          ),

        ),
      ),
    );
  }
}
