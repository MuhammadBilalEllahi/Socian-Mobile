import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'date_badge.dart';
import 'post_media.dart';
import 'post_stat_item.dart';

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

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          PostMedia(media: media),
          const SizedBox(height: 4),
          _buildActionButtons(),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Column(
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
      ),
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
          onTap: () {
            // TODO: Show comments
          },
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