import 'package:beyondtheclass/UI%20Pages/MyDrawer.dart';
import 'package:beyondtheclass/UI%20Pages/SimplePost.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/presentation/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'BreakingNewsScroller.dart';
import 'Filters.dart';
import 'QnA Post Widgets/QnAPost.dart';

class PostsPrimaryPage extends ConsumerStatefulWidget {
  const PostsPrimaryPage({super.key});

  @override
  _PostsPrimaryPageState createState() => _PostsPrimaryPageState();
}

class _PostsPrimaryPageState extends ConsumerState<PostsPrimaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 23.0,
            centerTitle: false,
            title: Text( AppConstants.appName, style: TextStyle(color: Colors.teal[800],fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: false,
            pinned: false, // This line makes the app bar scroll
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: [
                    SizedBox(
                      height: 50,
                      // color: Colors.brown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: const SizedBox(
                              width: 40,
                              // color: Colors.green,
                              child: Icon(Icons.menu_outlined),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.logout),
                                onPressed: () {
                                  ref.read(authProvider.notifier).logout();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AuthScreen()));
                                },
                              ),
                              SizedBox(
                                width: 40,
                                // color: Colors.blue,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const BreakingNewsScroller(
                                            newsText:
                                                'AAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                        Icons.notifications_none_outlined)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: SizedBox(
                        height: 50,
                        // color: Colors.red,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Filters(color: Colors.teal.shade900, text: "Latest Feed"),
                              Filters(color: Colors.tealAccent.shade400, text: "Ongoing"),
                              Filters(color: Colors.teal.shade900, text: "QnA"),
                              Filters(color: Colors.tealAccent.shade400, text: "Lost & Found"),
                              Filters(color: Colors.teal.shade900, text: "Polls"),
                              Filters(color: Colors.tealAccent.shade400, text: "Alerts"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SimplePost(),
                    const QnAPost(),
                    const SimplePost(),
                    const QnAPost(),
                    const SimplePost(),
                    const SimplePost(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Container(
          // width: 56, // Standard FAB diameter
          // height: 56,
          decoration: const BoxDecoration(
            // color: Colors.teal[200],
            shape: BoxShape.circle,
          ),
          child: FloatingActionButton(
            onPressed: () {},
            isExtended: true,
            backgroundColor: Colors.teal[600],
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
