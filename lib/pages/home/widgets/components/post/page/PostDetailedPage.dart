import 'package:beyondtheclass/pages/home/widgets/campus/widgets/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostDetailedPage extends StatefulWidget {
  final dynamic post;

  const PostDetailedPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailedPage> createState() => _PostDetailedPageState();
}

class _PostDetailedPageState extends State<PostDetailedPage> {
  bool isLiked = false;
  bool isDisliked = false;

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media'] as List?;
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // shadcn theme colors
    final background = isDark ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDark ? Colors.white : const Color(0xFF09090B);
    final muted = isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent = isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Post',
          style: TextStyle(color: foreground),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: foreground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(foreground, mutedForeground, formattedDate),
              const SizedBox(height: 16),
              _buildPostContent(foreground),
              if (media != null && media.isNotEmpty) ...[
                const SizedBox(height: 16),
                PostMedia(media: media),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(foreground, mutedForeground),
              const SizedBox(height: 16),
              _buildCommentsSection(foreground, mutedForeground),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(
      Color foreground, Color mutedForeground, String formattedDate) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.transparent,
          backgroundImage: widget.post['author'] != null &&
                  widget.post['author']['profile'] != null
              ? NetworkImage(widget.post['author']['profile']['picture'] ?? '')
              : const AssetImage('assets/default_profile_picture.png')
                  as ImageProvider,
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
                  fontSize: 16,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '@${widget.post['author']?['username'] ?? ''}',
                    style: TextStyle(
                      color: mutedForeground,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mutedForeground,
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
            color: foreground,
            size: 24,
          ),
          onPressed: () {
            // TODO: Show post options
          },
        ),
      ],
    );
  }

  Widget _buildPostContent(Color foreground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post['title'] ?? '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: foreground,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.post['body'] ?? '',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color foreground, Color mutedForeground) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          // foreground: foreground,
          // mutedForeground: mutedForeground,
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
          // foreground: foreground,
          // mutedForeground: mutedForeground,
        ),
        PostStatItem(
          icon: Icons.chat_bubble_outline,
          count: widget.post['commentsCount'] ?? 0,
          onTap: () {
            // TODO: Show comments
          },
          isActive: false,
          // foreground: foreground,
          // mutedForeground: mutedForeground,
        ),
        PostStatItem(
          icon: Icons.repeat,
          count: 0,
          onTap: () {
            // TODO: Implement repost
          },
          isActive: false,
          // foreground: foreground,
          // mutedForeground: mutedForeground,
        ),
      ],
    );
  }

  Widget _buildCommentsSection(Color foreground, Color mutedForeground) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
        const SizedBox(height: 16),
        // TODO: Implement comments list
        Center(
          child: Text(
            'No comments yet',
            style: TextStyle(
              color: mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
