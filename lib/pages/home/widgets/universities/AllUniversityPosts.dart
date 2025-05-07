import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/home/widgets/components/post/post.dart';
import 'package:flutter/material.dart';
import 'package:beyondtheclass/pages/home/widgets/universities/service/AllUniversityService.dart';
// import 'package:beyondtheclass/pages/home/widgets/universities/widgets/PostCard.dart';

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

    debugPrint('posts--------------: $posts');
    setState(() {
      _posts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return PostCard(
            post: _posts[index], flairType: Flairs.university.value);
        // PostCard(post: _posts[index],);
      },
    );
  }
}













////////////////////////////////////////////////////////////////////////////////////////////////
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:beyondtheclass/pages/home/widgets/components/post/post_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:beyondtheclass/pages/home/widgets/universities/service/AllUniversityService.dart';

// class AllUniversityPosts extends ConsumerStatefulWidget {
//   const AllUniversityPosts({super.key});

//   @override
//   ConsumerState<AllUniversityPosts> createState() => _AllUniversityPostsState();
// }

// class _AllUniversityPostsState extends ConsumerState<AllUniversityPosts> {
//   List<Map<String, dynamic>> _posts = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchPosts();
//   }

//   void _fetchPosts() async {
//     final posts = await AllUniversityService.getAllUniversityPosts();
//     debugPrint('posts--------------: $posts');
//     setState(() {
//       _posts = posts;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Read authProvider to get current user's data
//     final auth = ref.read(authProvider);
//     final currentUserUniversity =
//         auth.user?['university']?['universityId']?['name']?.toString() ?? 'Unknown';
//     debugPrint('Current user university: $currentUserUniversity');

//     return ListView.builder(
//       padding: const EdgeInsets.all(0),
//       itemCount: _posts.length,
//       itemBuilder: (context, index) {
//         // Extract university name for flair
//         final universityName =
//             _posts[index]['author']?['university']?['universityId']?['name']
//                     ?.toString() ??
//                 '';
//         return PostCard(
//           post: _posts[index],
//           flairType: 1, // Pass university name as flair
//         );
//       },
//     );
//   }
// }

