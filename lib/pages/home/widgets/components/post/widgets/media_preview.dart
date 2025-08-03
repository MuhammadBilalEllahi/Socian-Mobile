import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'package:video_player/video_player.dart';

class MediaPreview extends StatelessWidget {
  final List<File> mediaFiles;
  final Map<String, VideoPlayerController> videoControllers;
  final Function(int, bool) onMediaTap;
  final Function(int, bool) onMediaRemove;
  final List<Map<String, dynamic>> existingMedia;

  const MediaPreview({
    super.key,
    required this.mediaFiles,
    required this.videoControllers,
    required this.onMediaTap,
    required this.onMediaRemove,
    required this.existingMedia,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate total media count
    final existingMediaCount = existingMedia.length;
    final totalMediaCount = mediaFiles.length + existingMediaCount;

    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalMediaCount,
        itemBuilder: (context, index) {
          // Check if this is an existing media item or a new file
          final isExistingMedia = index < existingMediaCount;
          final mediaIndex =
              isExistingMedia ? index : index - existingMediaCount;

          if (isExistingMedia) {
            // Handle existing media from postData
            final mediaItem = existingMedia[mediaIndex];
            final isImage = mediaItem['type']?.startsWith('image/') ?? false;
            final isVideo = mediaItem['type']?.startsWith('video/') ?? false;

            return GestureDetector(
              onTap: () => onMediaTap(index, true),
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
                        CachedNetworkImage(
                          imageUrl: mediaItem['url'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        )
                      else if (isVideo)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(VideoPlayerController.network(
                                mediaItem['url'])),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
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
                            onPressed: () => onMediaRemove(index, true),
                          ),
                        ),
                      ),
                      if (totalMediaCount > 1)
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
                              '${index + 1}/$totalMediaCount',
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
          } else {
            // Handle new media files
            final file = mediaFiles[mediaIndex];
            final isImage = file.path.toLowerCase().endsWith('.jpg') ||
                file.path.toLowerCase().endsWith('.png') ||
                file.path.toLowerCase().endsWith('.jpeg');
            final isVideo = videoControllers.containsKey(file.path);

            return GestureDetector(
              onTap: () => onMediaTap(index, false),
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
                              aspectRatio: videoControllers[file.path]!
                                  .value
                                  .aspectRatio,
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
                                  if (videoControllers[file.path]!
                                      .value
                                      .isPlaying) {
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
                            onPressed: () => onMediaRemove(index, false),
                          ),
                        ),
                      ),
                      if (totalMediaCount > 1)
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
                              '${index + 1}/$totalMediaCount',
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
          }
        },
      ),
    );
  }
}
