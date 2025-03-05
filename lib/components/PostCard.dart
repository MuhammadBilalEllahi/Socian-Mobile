import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:video_player/video_player.dart'; // For video playback

class PostCard extends StatefulWidget {
  final dynamic post;
  final Color postsBgColor;
  final Color postsTextColor;

  const PostCard({
    super.key,
    required this.post,
    required this.postsBgColor,
    required this.postsTextColor,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isDisliked = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
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

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required BuildContext context,
    required Function onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
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

  Widget _buildDateBadge(String date, BuildContext context) {
    return Text(
      date,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildMedia(List<dynamic>? media) {
    if (media == null || media.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: media.map((item) {
          if (item['type']?.startsWith('image/') ?? false) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else if (item['type']?.startsWith('video/') ?? false) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
    );
  }

  void _showFullPostDialog(BuildContext context) {
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final upVotesCount = widget.post['voteId']?['upVotesCount'] ?? 0;
    final downVotesCount = widget.post['voteId']?['downVotesCount'] ?? 0;
    final commentsCount = widget.post['commentsCount'] ?? 0;
    final media = widget.post['media'] as List?;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 32, 32, 32).withOpacity(0.3),
                    const Color.fromARGB(255, 49, 49, 49).withOpacity(0.4),
                    const Color.fromARGB(255, 42, 42, 42).withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 50, 50, 50).withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(3, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(-3, -3),
                  ),
                ],
              ),
              child: Dialog.fullscreen(
                backgroundColor: widget.postsBgColor,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 67, 67, 67).withOpacity(0.3),
                        const Color.fromARGB(255, 54, 54, 54).withOpacity(0.4),
                        const Color.fromARGB(255, 8, 8, 8).withOpacity(0.1),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: widget.post['author'] != null && widget.post['author']['profile'] != null
                                ? NetworkImage(widget.post['author']['profile']['picture'] ?? '')
                                : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post['author']?['name'] ?? '{Deleted}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: widget.postsTextColor),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '@${widget.post['author']?['username'] ?? ''}',
                                    style: TextStyle(fontSize: 12, color: widget.postsTextColor),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(Icons.circle, size: 5, color: widget.postsTextColor),
                                  const SizedBox(width: 5),
                                  _buildDateBadge(formattedDate, context),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close, color: widget.postsTextColor),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post['title'] ?? '',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.postsTextColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.post['body'] ?? '',
                                style: TextStyle(fontSize: 14, color: widget.postsTextColor),
                              ),
                              const SizedBox(height: 16),
                              _buildMedia(media),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      _buildStatItem(
                                        icon: Icons.favorite,
                                        count: upVotesCount,
                                        context: context,
                                        onTap: () {
                                          setState(() {
                                            isLiked = !isLiked;
                                            if (isLiked) {
                                              isDisliked = false;
                                            }
                                          });
                                        },
                                        isActive: isLiked,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatItem(
                                        icon: Icons.thumb_down,
                                        count: downVotesCount,
                                        context: context,
                                        onTap: () {
                                          setState(() {
                                            isDisliked = !isDisliked;
                                            if (isDisliked) {
                                              isLiked = false;
                                            }
                                          });
                                        },
                                        isActive: isDisliked,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatItem(
                                        icon: Icons.chat_bubble_outline,
                                        count: commentsCount,
                                        context: context,
                                        onTap: () {},
                                        isActive: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
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
          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
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
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '@${widget.post['author']?['username'] ?? ''}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 13,
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
                        _buildDateBadge(formattedDate, context),
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
          ),
          const SizedBox(height: 16),
          // Post Content
          Text(
            widget.post['title'] ?? '',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.post['body'] ?? '',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          // Media Content
          _buildMedia(media),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.favorite_outline,
                count: widget.post['voteId']?['upVotesCount'] ?? 0,
                context: context,
                onTap: () {
                  setState(() {
                    isLiked = !isLiked;
                    if (isLiked) {
                      isDisliked = false;
                    }
                  });
                },
                isActive: isLiked,
              ),
              _buildStatItem(
                icon: Icons.thumb_down_outlined,
                count: widget.post['voteId']?['downVotesCount'] ?? 0,
                context: context,
                onTap: () {
                  setState(() {
                    isDisliked = !isDisliked;
                    if (isDisliked) {
                      isLiked = false;
                    }
                  });
                },
                isActive: isDisliked,
              ),
              _buildStatItem(
                icon: Icons.chat_bubble_outline,
                count: widget.post['commentsCount'] ?? 0,
                context: context,
                onTap: () {
                  // TODO: Show comments
                },
                isActive: false,
              ),
              _buildStatItem(
                icon: Icons.repeat,
                count: 0,
                context: context,
                onTap: () {
                  // TODO: Implement repost
                },
                isActive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}