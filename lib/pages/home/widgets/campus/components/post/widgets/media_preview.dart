import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../create_post.dart';

class MediaPreview extends StatelessWidget {
  final List<File> mediaFiles;
  final Map<String, VideoPlayerController> videoControllers;
  final Function(int) onMediaTap;
  final Function(int) onMediaRemove;

  const MediaPreview({
    super.key,
    required this.mediaFiles,
    required this.videoControllers,
    required this.onMediaTap,
    required this.onMediaRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mediaFiles.length,
        itemBuilder: (context, index) {
          final file = mediaFiles[index];
          final isImage = file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.png') ||
              file.path.toLowerCase().endsWith('.jpeg');
          final isVideo = videoControllers.containsKey(file.path);
          
          return GestureDetector(
            onTap: () => onMediaTap(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isImage)
                      Image.file(
                        file,
                        fit: BoxFit.cover,
                      )
                    else if (isVideo)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: videoControllers[file.path]!.value.aspectRatio,
                            child: VideoPlayer(videoControllers[file.path]!),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                videoControllers[file.path]!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (videoControllers[file.path]!.value.isPlaying) {
                                  videoControllers[file.path]!.pause();
                                } else {
                                  videoControllers[file.path]!.play();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => onMediaRemove(index),
                        ),
                      ),
                    ),
                    if (mediaFiles.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${mediaFiles.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 