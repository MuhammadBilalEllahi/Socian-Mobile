import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PostCardDialog extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCardDialog({super.key, required this.post});

  @override
  State<PostCardDialog> createState() => _PostCardDialogState();
}

class _PostCardDialogState extends State<PostCardDialog> {
  int _currentMediaIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> mediaList = widget.post['media'] ?? [];
    
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.post['title'] ?? 'No Title',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Media carousel if available
            if (mediaList.isNotEmpty) ...[
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: mediaList.length > 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentMediaIndex = index;
                    });
                  },
                ),
                items: mediaList.map((media) {
                  final bool isVideo = media['type'] == 'video';
                  
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isVideo
                        ? Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  media['thumbnail'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Text('Video Thumbnail Not Available')),
                                ),
                                const Icon(
                                  Icons.play_circle_fill,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        : Image.network(
                            media['url'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Text('Image Not Available')),
                          ),
                  );
                }).toList(),
              ),
              
              // Carousel indicator
              if (mediaList.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: mediaList.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentMediaIndex == entry.key
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
            ],
            
            // Post content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author info
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            widget.post['author']?['profile']?['picture'] ?? 
                            'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg',
                          ),
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.post['author']?['name'] ?? 'Anonymous',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Post body
                    Text(
                      widget.post['body'] ?? 'No content',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    
                    // Post metadata
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.thumb_up_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text('${widget.post['upvotes'] ?? 0}'),
                            const SizedBox(width: 16),
                            const Icon(Icons.thumb_down_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text('${widget.post['downvotes'] ?? 0}'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.comment_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text('${widget.post['commentsCount'] ?? 0}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_outlined),
                    onPressed: () {
                      // Implement upvote functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_down_outlined),
                    onPressed: () {
                      // Implement downvote functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () {
                      // Implement comment functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      // Implement share functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
