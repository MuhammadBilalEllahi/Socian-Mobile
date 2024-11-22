import 'package:flutter/material.dart';

class SimplePost extends StatefulWidget {
  const SimplePost({super.key});

  @override
  State<SimplePost> createState() => _SimplePostState();
}

class _SimplePostState extends State<SimplePost> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: Container(
        height: 400,
        // color: Colors.red,
        child: Column(
          children: [
            // Profile Pic row
            Row(
              children: [
                // The Profile Pic
                Container(
                  // height: 50,
                  // width: 50,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("assets/images/profilepic2.jpg"),
                  ),
                ),
                SizedBox(width: 10,),
                //Name & dept.
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Muhammad Rayyan"),
                      Text("CS",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ],
            ),
            // Caption row
            Row(
              children: [
                Expanded(
                  child: Text("Lorem ipsum Quisque blandit dolor vel ullamcorper fringilla. "
                      "Etiam ut ultricies nibh. Maecenas sit amet ipsum",),
                )
              ],
            ),
            // Picture
            Container(
              height: 250,
              child: Image.asset("assets/images/anime2.png",fit: BoxFit.fill,)
            ),
            SizedBox(height: 5,),
            // Like comment row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // buttons
                Column(
                  children: [
                    Row(
                      children: [
                        // SizedBox(width: 10,),
                        Icon(Icons.thumb_up_outlined),
                        Text("10",),
                        SizedBox(width: 10,),
                        Icon(Icons.mode_comment_outlined),
                        Text("6",),
      
                      ],
                    )
                  ],
                ),
                Column(
                  children: [
                    Text("10 min ago",style: TextStyle(fontSize: 10,color: Colors.grey),)
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
