import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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