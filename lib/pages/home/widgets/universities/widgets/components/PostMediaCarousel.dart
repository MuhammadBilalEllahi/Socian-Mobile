import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';

class PostMediaCarousel extends StatefulWidget {
  final List<dynamic> mediaList;
  final int currentIndex;
  final Function(int) onPageChanged;

  const PostMediaCarousel({
    super.key,
    required this.mediaList,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  State<PostMediaCarousel> createState() => _PostMediaCarouselState();
}

class _PostMediaCarouselState extends State<PostMediaCarousel> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.mediaList.isNotEmpty) {
      final video = widget.mediaList.firstWhere(
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

  void _togglePlayPause() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        if (_isPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
        _isPlaying = !_isPlaying;
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    
    // Auto-hide controls after a few seconds if video is playing
    if (_showControls && _isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CarouselSlider(
        options: CarouselOptions(
          height: size.height,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          enableInfiniteScroll: widget.mediaList.length > 1,
          onPageChanged: (index, reason) {
            widget.onPageChanged(index);
            // Pause video when changing pages
            if (_videoController != null && _videoController!.value.isPlaying) {
              _videoController!.pause();
              setState(() {
                _isPlaying = false;
                _showControls = true;
              });
            }
          },
        ),
        items: widget.mediaList.map((media) {
          final bool isVideo = media['type']?.startsWith('video/') ?? false;
          
          return Container(
            width: size.width,
            height: size.height,
            margin: EdgeInsets.zero,
            child: isVideo
                ? _buildVideoItem(media)
                : _buildImageItem(media),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVideoItem(dynamic media) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_videoController != null && _videoController!.value.isInitialized)
          GestureDetector(
            onTap: _toggleControls,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(_videoController!),
            ),
          )
        else
          Image.network(
            media['thumbnail'] ?? '',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Text('Video Thumbnail Not Available')),
          ),
        if (_showControls)
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(dynamic media) {
    return Image.network(
      media['url'] ?? '',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Text('Image Not Available')),
    );
  }
} 