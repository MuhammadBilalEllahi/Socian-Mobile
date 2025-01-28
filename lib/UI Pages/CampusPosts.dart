import 'package:flutter/material.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';

class CampusPosts extends StatefulWidget {
  const CampusPosts({super.key});

  @override
  _CampusPostsState createState() => _CampusPostsState();
}

class _CampusPostsState extends State<CampusPosts> {
  late Future<List<dynamic>> posts = Future.value([]);
  final ApiClient apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void fetchPosts() async {
    try {
      final response = await apiClient.get(ApiConstants.postsCampus); // Replace with the correct endpoint

      print("API Response: $response"); // Print the entire response to inspect
      print("Response type: ${response.runtimeType}"); // Print the type of the response to verify it

      // Check if response is a List
      if (response is List) {
        setState(() {
          posts = Future.value(response); // Directly assign the list of posts
        });
      } else {
        setState(() {
          posts = Future.error('Invalid API response format: $response');
        });
      }
    } catch (e) {
      setState(() {
        posts = Future.error('Failed to load posts: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Campus Posts',
          style: TextStyle(
            color: Colors.teal.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Posts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('${snapshot.error}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          } else if (snapshot.data?.isEmpty ?? true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.list, color: Colors.grey, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'No Posts Available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } else {
            final postList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: postList.length,
              itemBuilder: (context, index) {
                final post = postList[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.shade900,
                          Colors.tealAccent.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // CircleAvatar(
                              //   backgroundColor: Colors.white,
                              //   child: Text(
                              //     post['title']?.isNotEmpty == true
                              //         ? post['title'][0]
                              //         : '?',
                              //     style: const TextStyle(color: Colors.teal),
                              //   ),
                              // ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(post['author']['profile']['picture']),
                              ),

                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  post['title'] ?? 'Untitled',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post['body'] ?? 'No body available',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Like',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Comment',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              Text(
                                '2 hours ago',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


