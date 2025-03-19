import 'package:flutter/material.dart';
import 'package:beyondtheclass/pages/home/widgets/universities/service/AllUniversityService.dart';
import 'package:beyondtheclass/pages/home/widgets/universities/widgets/PostCard.dart';

class AllUniversityPosts extends StatefulWidget {
  const AllUniversityPosts({super.key});

  @override
  State<AllUniversityPosts> createState() => _AllUniversityPostsState();
}

class _AllUniversityPostsState extends State<AllUniversityPosts> {
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() async {
    final posts = await AllUniversityService.getAllUniversityPosts();
    setState(() {
      _posts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
      return   ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: _posts[index]);
        },
    );
  }
}
