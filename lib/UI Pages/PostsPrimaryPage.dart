import 'package:beyondtheclass/UI%20Pages/MyDrawer.dart';
import 'package:beyondtheclass/UI%20Pages/SimplePost.dart';
import 'package:flutter/material.dart';

import 'BreakingNewsScroller.dart';
import 'Filters.dart';
import 'QnA Post Widgets/QnAPost.dart';

class PostsPrimaryPage extends StatefulWidget {
  const PostsPrimaryPage({super.key});

  @override
  State<PostsPrimaryPage> createState() => _PostsPrimaryPageState();
}

class _PostsPrimaryPageState extends State<PostsPrimaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 23.0,
            centerTitle: false,
            title: Text("Beyond The Class"),
            automaticallyImplyLeading: false,
            pinned: false, // This line makes the app bar scroll
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: [
                    Container(
                      height: 50,
                      // color: Colors.brown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                              width: 40,
                              // color: Colors.green,
                              child: Icon(Icons.menu_outlined),
                            ),
                          ),
                          Row(
                            children: [

                              Container(
                                width: 40,
                                // color: Colors.blue,
                                child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => BreakingNewsScroller(
                                            newsText: 'AAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC',
                                          ),),

                                      );
                                    },
                                    child: Icon(Icons.notifications_none_outlined)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Container(
                        height: 50,
                        // color: Colors.red,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Filters(color: Colors.blue, text: "Latest Feed"),
                              Filters(color: Colors.red, text: "Ongoing"),
                              Filters(color: Colors.greenAccent, text: "QnA"),
                              Filters(color: Colors.purple, text: "Lost & Found"),
                              Filters(color: Colors.brown, text: "Polls"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SimplePost(),
                    QnAPost(),
                    SimplePost(),
                    QnAPost(),
                    SimplePost(),
                    SimplePost(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),

      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Container(
          // width: 56, // Standard FAB diameter
          // height: 56,
          decoration: BoxDecoration(
            // color: Colors.teal[200],
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            onPressed: (){},
            isExtended: true,
            backgroundColor: Colors.teal[600],
            child: Icon(Icons.edit,color: Colors.white,),

          ),
        ),
      ),
    );
  }
}