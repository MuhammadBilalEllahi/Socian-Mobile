import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../components/PostMediaCarousel.dart';
import '../components/PostHeader.dart';
import '../components/PostContent.dart';
import '../components/CommentsBottomSheet.dart';
import '../../service/AllUniversityService.dart';

class PostViewPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostViewPage({
    super.key,
    required this.post,
  });

  @override
  State<PostViewPage> createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  bool isLiked = false;
  bool isDisliked = false;
  int currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post['voteId']?['userVotes']?['upvote'] ?? false;
    isDisliked = widget.post['voteId']?['userVotes']?['downvote'] ?? false;
  }

  void _handleVote(String voteType) async {
    try {
      await AllUniversityService.votePost(widget.post['_id'], voteType);
      setState(() {
        if (voteType == 'upvote') {
          isLiked = !isLiked;
          if (isLiked) isDisliked = false;
        } else if (voteType == 'downvote') {
          isDisliked = !isDisliked;
          if (isDisliked) isLiked = false;
        }
      });
    } catch (e) {
      debugPrint('Error voting: $e');
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(postId: widget.post['_id']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaList = widget.post['media'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen media - positioned first to be accessible for gestures
          if (mediaList.isNotEmpty)
            Positioned.fill(
              child: PostMediaCarousel(
                mediaList: mediaList,
                currentIndex: currentMediaIndex,
                onPageChanged: (index) {
                  setState(() {
                    currentMediaIndex = index;
                  });
                },
              ),
            ),

          // Gradient overlay for better text visibility - positioned after media to allow gestures to pass through
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.4, // Only cover bottom portion
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          // TODO: Show post options
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Bottom content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: widget.post['author'] != null && 
                                widget.post['author']['profile'] != null
                                ? NetworkImage(widget.post['author']['profile']['picture'] ?? '')
                                : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post['author']?['name'] ?? '{Deleted}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '@${widget.post['author']?['username'] ?? ''}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Post content
                      if (widget.post['title']?.isNotEmpty ?? false)
                        Text(
                          widget.post['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (widget.post['body']?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.post['body'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vertical action buttons
          Positioned(
            right: 16,
            bottom: 20,
            child: Column(
              children: [
                _buildVerticalActionButton(
                  icon: Icons.favorite_outline,
                  count: widget.post['voteId']?['upVotesCount'] ?? 0,
                  isActive: isLiked,
                  onTap: () => _handleVote('upvote'),
                ),
                const SizedBox(height: 16),
                _buildVerticalActionButton(
                  icon: Icons.thumb_down_outlined,
                  count: widget.post['voteId']?['downVotesCount'] ?? 0,
                  isActive: isDisliked,
                  onTap: () => _handleVote('downvote'),
                ),
                const SizedBox(height: 16),
                _buildVerticalActionButton(
                  icon: Icons.chat_bubble_outline,
                  count: widget.post['commentsCount'] ?? 0,
                  isActive: false,
                  onTap: _showComments,
                ),
                const SizedBox(height: 16),
                _buildVerticalActionButton(
                  icon: Icons.repeat,
                  count: 0,
                  isActive: false,
                  onTap: () {
                    // TODO: Implement repost
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalActionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.red : Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            count > 0 ? count.toString() : '0',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 