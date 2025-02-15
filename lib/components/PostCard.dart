
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

  Widget _buildStatItem({required IconData emoji, required int count, required BuildContext context, required Function onTap, required Color activeColor, required bool isActive}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : (Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(
            //   emoji,
            //   style: const TextStyle(fontSize: 18),
            // ),
            Icon(emoji),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBadge(String date, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded, size: 10,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildMedia(List<dynamic>? media) {
    if (media == null || media.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200, // Adjust height as needed
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: media.map((item) {
            if (item['type']?.startsWith('image/') ?? false) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['url'],
                    width: 200, // Set a fixed width for images
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else if (item['type']?.startsWith('video/') ?? false) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _videoController != null && _videoController!.value.isInitialized
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
                    : const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }).toList(),
        ),
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
                                        emoji: Icons.thumb_up_alt,
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
                                        activeColor: const Color.fromARGB(255, 55, 55, 55),
                                        isActive: isLiked,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatItem(
                                        emoji: Icons.thumb_down,
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
                                        activeColor: Colors.red,
                                        isActive: isDisliked,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatItem(
                                        emoji: Icons.reply,
                                        count: commentsCount,
                                        context: context,
                                        onTap: () {},
                                        activeColor: Colors.transparent,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: widget.postsBgColor,
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
                      const Color.fromARGB(255, 61, 61, 61).withOpacity(0.3),
                      const Color.fromARGB(255, 35, 35, 35).withOpacity(0.4),
                      const Color.fromARGB(255, 50, 50, 50).withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
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
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
                                  const SizedBox(width: 5,),
                                  Icon(Icons.circle, size: 5, color: widget.postsTextColor),
                                  const SizedBox(width: 5,),
                                  _buildDateBadge(DateFormat('MMM d, y').format(DateTime.parse(widget.post['createdAt'])), context),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.more_vert, color: widget.postsTextColor),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showFullPostDialog(context),
                        child: Text(
                          widget.post['title'] ?? '',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.postsTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showFullPostDialog(context),
                        child: Text(
                          widget.post['body'] ?? '',
                          style: TextStyle(fontSize: 13, color: widget.postsTextColor),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildMedia(media),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildStatItem(
                                emoji: Icons.thumb_up_alt,
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
                                activeColor: Colors.green,
                                isActive: isLiked,
                              ),
                              const SizedBox(width: 8),
                              _buildStatItem(
                                emoji: Icons.thumb_down,
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
                                activeColor: Colors.red,
                                isActive: isDisliked,
                              ),
                              const SizedBox(width: 8),
                              _buildStatItem(
                                emoji: Icons.reply,
                                count: widget.post['commentsCount'] ?? 0,
                                context: context,
                                onTap: () {},
                                activeColor: Colors.transparent,
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
            ),
          ),
        ),
      ),
    );
  }
}