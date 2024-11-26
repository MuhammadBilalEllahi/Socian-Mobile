import 'package:flutter/material.dart';

import 'PostButton.dart';
import 'QnAThumbnailCard.dart';
import 'YourAnswerTextField.dart';

class QnAPost extends StatefulWidget {
  const QnAPost({super.key});

  @override
  State<QnAPost> createState() => _QnAPostState();
}

class _QnAPostState extends State<QnAPost> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // for profile pic and name etc.
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                // The Profile Pic
                Container(
                  // height: 50,
                  // width: 50,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("assets/images/profilepic.jpg"),
                  ),
                ),
                SizedBox(width: 10,),
                //Name & dept.
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Muhammad Bilal Ellahi"),
                      Text("PHY",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Text("Seniors! I need guidance. Do I need to focus on OOP and DSA concepts more and take Modern Physics lightly. Or focus on every course"),
          ),
          SingleChildScrollView(scrollDirection:Axis.horizontal, child: Row(children: [
            QnAThumbnailCard(),
            QnAThumbnailCard(),
            QnAThumbnailCard(),
            QnAThumbnailCard(),

          ],),),
          Row(mainAxisAlignment: MainAxisAlignment.end,children: [Text("15 answers",style: TextStyle(color: Colors.grey),),SizedBox(width: 5,)],),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              YourAnswerTextField(),
              SizedBox(width: 10,),
              PostButton(),
            ],
          ),

        ],
      ),
    );
  }
}
