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
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Container(
        // height: 400,
        // color: Colors.red,
        child: Column(
          children: [
            // Profile Pic row
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    Row(children: [// The Profile Pic
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
                            Text("Muhammad Rayyan",style: TextStyle(fontSize: 16),),
                            Row(
                              children: [
                                Text("CS",style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                                SizedBox(width: 5,),
                                Icon(Icons.circle,size: 6,),
                                SizedBox(width: 5,),
                                Text("10 min ago",style: TextStyle(fontSize: 12,color: Colors.grey),)
                              ],
                            )
                          ],
                        ),
                      ),],),

                  ],),
                  Column(children: [
                    Icon(Icons.more_horiz,size: 24,)
                  ],),
                ],
              ),
            ),
            // Caption row
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text("Lorem ipsum Quisque blandit dolor vel ullamcorper fringilla. "
                        "Etiam ut ultricies nibh. Maecenas sit amet ipsum",),
                  )
                ],
              ),
            ),
            // Picture
            Container(
              height: 250,
              child: Image.asset("assets/images/anime2.png",fit: BoxFit.fill,)
            ),
            SizedBox(height: 5,),
            // Like comment row
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // SizedBox(width: 10,),
                      Icon(Icons.thumb_up_outlined,size: 30,),
                      Text("10",style: TextStyle(fontSize:18 ),),
                      SizedBox(width: 10,),
                      Icon(Icons.mode_comment_outlined, size: 30,),
                      Text("6",style: TextStyle(fontSize:18 ),),

                    ],
                  )
                ],
              ),
            ),
          ],
        ),


      ),
    );
  }
}
