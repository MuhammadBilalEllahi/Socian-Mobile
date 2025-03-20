import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dialog/PostViewPage.dart';

// Reusable stateless widget for post stats
class PostStatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final bool isActive;

  const PostStatItem({
    super.key,
    required this.icon,
    required this.count,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.red.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.red : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              count > 0 ? count.toString() : '',
              style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.red : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable stateless widget for date badge
class DateBadge extends StatelessWidget {
  final String date;

  const DateBadge({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      date,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[600],
      ),
    );
  }
}

// Reusable stateful widget for media content
class PostMedia extends StatefulWidget {
  final List<dynamic>? media;

  const PostMedia({
    super.key,
    required this.media,
  });

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.media != null && widget.media!.isNotEmpty) {
      final video = widget.media!.firstWhere(
        (element) => element['type']?.startsWith('video/') ?? false,
        orElse: () => null,
      );
      if (video != null) {
        _videoController = VideoPlayerController.network(video['url'])
          ..initialize().then((_) {
            setState(() {});
          });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media == null || widget.media!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: Column(
        children: widget.media!.map((item) {
          if (item['type']?.startsWith('image/') ?? false) {
            return _buildImageItem(item);
          } else if (item['type']?.startsWith('video/') ?? false) {
            return _buildVideoItem();
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  Widget _buildImageItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(0, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          item['url'],
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVideoItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _videoController != null && _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            : const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }
}

// Main PostCard widget
class PostCard extends StatefulWidget {
  final dynamic post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isDisliked = false;
  int currentMediaIndex = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post['voteId']?['userVotes']?['upvote'] ?? false;
    isDisliked = widget.post['voteId']?['userVotes']?['downvote'] ?? false;
    _initializeVideo();
  }

  void _initializeVideo() {
    final media = widget.post['media'] as List?;
    if (media != null && media.isNotEmpty) {
      final video = media.firstWhere(
        (element) => element['type']?.startsWith('video/') ?? false,
        orElse: () => null,
      );
      if (video != null) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(video['url']))
          ..initialize().then((_) {
            setState(() {});
          });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _showPostView() {
    showDialog(
      context: context,
      builder: (context) => PostViewPage(post: widget.post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _showPostView,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color.fromARGB(0, 0, 0, 0) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(isDark, formattedDate),
            const SizedBox(height: 8),
            _buildPostContent(isDark),
            if (media != null && media.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildMediaCarousel(media),
            ],
            const SizedBox(height: 4),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(bool isDark, String formattedDate) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          backgroundImage: widget.post['author'] != null && widget.post['author']['profile'] != null
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  Text(
                    '@${widget.post['author']?['username'] ?? ''}',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DateBadge(date: formattedDate),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            // TODO: Show post options
          },
        ),
      ],
    );
  }

  Widget _buildPostContent(bool isDark) {
    return Padding(padding: const EdgeInsets.only(left: 6), 
    child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post['title'] ?? '',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.post['body'] ?? '',
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    )
  );
  }

  Widget _buildMediaCarousel(List media) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                currentMediaIndex = index;
              });
            },
          ),
          items: media.map((item) {
            if (item['type']?.startsWith('image/') ?? false) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['url'],
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            } else if (item['type']?.startsWith('video/') ?? false) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const SizedBox(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ),
        if (media.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: media.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.key == currentMediaIndex
                      ? Colors.blue
                      : Colors.grey[300],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PostStatItem(
          icon: Icons.favorite_outline,
          count: widget.post['voteId']?['upVotesCount'] ?? 0,
          onTap: () {
            setState(() {
              isLiked = !isLiked;
              if (isLiked) isDisliked = false;
            });
          },
          isActive: isLiked,
        ),
        PostStatItem(
          icon: Icons.thumb_down_outlined,
          count: widget.post['voteId']?['downVotesCount'] ?? 0,
          onTap: () {
            setState(() {
              isDisliked = !isDisliked;
              if (isDisliked) isLiked = false;
            });
          },
          isActive: isDisliked,
        ),
        PostStatItem(
          icon: Icons.chat_bubble_outline,
          count: widget.post['commentsCount'] ?? 0,
          onTap: _showPostView,
          isActive: false,
        ),
        PostStatItem(
          icon: Icons.repeat,
          count: 0,
          onTap: () {
            // TODO: Implement repost
          },
          isActive: false,
        ),
      ],
    );
  }
}