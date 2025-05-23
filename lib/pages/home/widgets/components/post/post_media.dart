import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const key = "customCache";

  static final CustomCacheManager _instance = CustomCacheManager._();

  factory CustomCacheManager() {
    return _instance;
  }

  CustomCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 3),
            maxNrOfCacheObjects: 100, // Limit to 100 files
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}

class PostMedia extends StatefulWidget {
  final List<dynamic>? media;

  const PostMedia({
    super.key,
    required this.media,
  });

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  CachedVideoPlayerPlusController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late AnimationController _waveformController;
  final List<double> _waveform =
      List.generate(50, (index) => math.Random().nextDouble() * 0.5 + 0.5);
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _cachedMediaWidgets = [];

  @override
  void initState() {
    super.initState();

    _initializeVideo();
    _initializeAudio();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Initialize media widgets after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeMediaWidgets();
        _preloadAdjacentImages(0);
      }
    });
  }

  void _initializeMediaWidgets() {
    if (widget.media == null || widget.media!.isEmpty) return;

    _cachedMediaWidgets.clear();
    for (final item in widget.media!) {
      if (item['type']?.startsWith('image/') ?? false) {
        _cachedMediaWidgets.add(_buildImageItem(item, true));
      } else if (item['type']?.startsWith('video/') ?? false) {
        _cachedMediaWidgets.add(_buildVideoItem());
      } else if (item['type']?.startsWith('audio/') ?? false) {
        _cachedMediaWidgets.add(_buildAudioItem());
      }
    }
  }

  // Modify _buildImageItem to accept a cache flag
  Widget _buildImageItem(dynamic item, [bool forCache = false]) {
    // Preload the image
    precacheImage(CachedNetworkImageProvider(item['url']), context);

    return KeepAliveWrapper(
      child: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(0, 0, 0, 0),
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: GestureDetector(
          onTap: forCache
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenMediaView(
                        mediaFiles: [item['url']],
                        initialIndex: 0,
                        videoControllers: {},
                        isImage: true,
                      ),
                    ),
                  );
                },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: item['url'],
              cacheManager: CustomCacheManager(),
              width: double.infinity,
              height: 350,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  void _preloadAdjacentImages(int currentIndex) {
    // Preload next 2 images
    for (int i = 1; i <= 2; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < widget.media!.length) {
        final nextItem = widget.media![nextIndex];
        if (nextItem['type']?.startsWith('image/') ?? false) {
          precacheImage(CachedNetworkImageProvider(nextItem['url']), context);
        }
      }
    }

    // Optionally preload previous 1 image
    final prevIndex = currentIndex - 1;
    if (prevIndex >= 0) {
      final prevItem = widget.media![prevIndex];
      if (prevItem['type']?.startsWith('image/') ?? false) {
        precacheImage(CachedNetworkImageProvider(prevItem['url']), context);
      }
    }
  }

  void _initializeVideo() {
    if (widget.media != null && widget.media!.isNotEmpty) {
      final video = widget.media!.firstWhere(
        (element) => element['type']?.startsWith('video/') ?? false,
        orElse: () => null,
      );
      if (video != null) {
        _videoController = CachedVideoPlayerPlusController.networkUrl(
          Uri.parse(video['url']),
          httpHeaders: {
            'Connection': 'keep-alive',
          },
          invalidateCacheIfOlderThan: const Duration(hours: 4),
        );
        _videoController!.addListener(() {
          if (mounted) setState(() {});
        });
        _videoController!.initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController!.setLooping(true);
          }
        });
      }
    }
  }

  void _initializeAudio() {
    if (widget.media != null && widget.media!.isNotEmpty) {
      final audio = widget.media!.firstWhere(
        (element) => element['type']?.startsWith('audio/') ?? false,
        orElse: () => null,
      );
      if (audio != null) {
        _audioPlayer = AudioPlayer();
        _audioPlayer!.onPlayerStateChanged.listen((state) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        });
        _audioPlayer!.onDurationChanged.listen((duration) {
          setState(() {
            _duration = duration;
          });
        });
        _audioPlayer!.onPositionChanged.listen((position) {
          setState(() {
            _position = position;
          });
        });
        _audioPlayer!.setSourceUrl(audio['url']);
      }
    }
  }

  Future<void> _playPauseAudio() async {
    if (_audioPlayer == null) return;
    if (_isPlaying) {
      await _audioPlayer!.pause();
    } else {
      await _audioPlayer!.resume();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _videoController?.removeListener(() {
      if (mounted) setState(() {});
    });
    _videoController?.dispose();
    _audioPlayer?.dispose();
    _waveformController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.media == null || widget.media!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 0),
          height: 350,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  // Preload next 2 images when page changes
                  _preloadAdjacentImages(index);
                },
                itemCount: widget.media!.length,
                itemBuilder: (context, index) {
                  final item = widget.media![index];
                  if (item['type']?.startsWith('image/') ?? false) {
                    return _buildImageItem(item);
                  } else if (item['type']?.startsWith('video/') ?? false) {
                    return _buildVideoItem();
                  } else if (item['type']?.startsWith('audio/') ?? false) {
                    return _buildAudioItem();
                  }
                  return const SizedBox.shrink();
                },
              ),
              if (widget.media!.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.media!.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildImageItem(dynamic item) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 0),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: const [
  //         BoxShadow(
  //           color: Color.fromARGB(0, 0, 0, 0),
  //           blurRadius: 4,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: GestureDetector(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => FullScreenMediaView(
  //               mediaFiles: [item['url']],
  //               initialIndex: 0,
  //               videoControllers: {},
  //               isImage: true,
  //             ),
  //           ),
  //         );
  //       },
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: CachedNetworkImage(
  //           imageUrl: item['url'],
  //           width: double.infinity,
  //           height: 350,
  //           fit: BoxFit.contain,
  //           placeholder: (context, url) => const Center(
  //             child: CircularProgressIndicator(),
  //           ),
  //           errorWidget: (context, url, error) => const Icon(Icons.error),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildVideoItem() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      height: 350,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              SizedBox(
                height: 350,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: CachedVideoPlayerPlus(_videoController!),
                  ),
                ),
              )
            else
              const SizedBox(
                height: 350,
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbColor: Colors.white,
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                          ),
                          child: Slider(
                            value: _videoController!
                                .value.position.inMilliseconds
                                .toDouble(),
                            min: 0.0,
                            max: _videoController!.value.duration.inMilliseconds
                                .toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _videoController!.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(_videoController!.value.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_videoController!.value.duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenMediaView(
                                mediaFiles: [_videoController!.dataSource],
                                initialIndex: 0,
                                videoControllers: {
                                  _videoController!.dataSource:
                                      _videoController!
                                },
                                isImage: false,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioItem() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    

    return Container(
      width: double.minPositive,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: _playPauseAudio,
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 24,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _waveformController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 32),
                          painter: WaveformPainter(
                            waveform: _waveform,
                            progress: _position.inMilliseconds /
                                _duration.inMilliseconds,
                            isPlaying: _isPlaying,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final double progress;
  final bool isPlaying;
  final Color color;

  WaveformPainter({
    required this.waveform,
    required this.progress,
    required this.isPlaying,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final barWidth = width / waveform.length;
    final progressWidth = width * progress;

    for (var i = 0; i < waveform.length; i++) {
      final x = i * barWidth;
      final barHeight = waveform[i] * height;
      final y = (height - barHeight) / 2;

      if (x < progressWidth) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + barHeight),
          progressPaint,
        );
      } else {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + barHeight),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return waveform != oldDelegate.waveform ||
        progress != oldDelegate.progress ||
        isPlaying != oldDelegate.isPlaying ||
        color != oldDelegate.color;
  }
}

// Add this wrapper class to keep each page alive
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

class FullScreenMediaView extends StatefulWidget {
  final List<String> mediaFiles;
  final Map<String, CachedVideoPlayerPlusController> videoControllers;
  final int initialIndex;
  final bool isImage;

  const FullScreenMediaView({
    super.key,
    required this.mediaFiles,
    required this.videoControllers,
    required this.initialIndex,
    required this.isImage,
  });

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late PageController _pageController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    // Add listeners to all video controllers
    widget.videoControllers.values.forEach((controller) {
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Remove listeners from all video controllers
    widget.videoControllers.values.forEach((controller) {
      controller.removeListener(() {
        if (mounted) setState(() {});
      });
    });
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaFiles.length,
            itemBuilder: (context, index) {
              final file = widget.mediaFiles[index];
              final isVideo = widget.videoControllers.containsKey(file);

              if (isVideo) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio:
                            widget.videoControllers[file]!.value.aspectRatio,
                        child: CachedVideoPlayerPlus(
                            widget.videoControllers[file]!),
                      ),
                      if (_showControls)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (widget.videoControllers[file]!.value
                                          .isPlaying) {
                                        widget.videoControllers[file]!.pause();
                                      } else {
                                        widget.videoControllers[file]!.play();
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    widget.videoControllers[file]!.value
                                            .isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      thumbColor: Colors.white,
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor:
                                          Colors.white.withOpacity(0.3),
                                      trackHeight: 2,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                        overlayRadius: 12,
                                      ),
                                    ),
                                    child: Slider(
                                      value: widget.videoControllers[file]!
                                          .value.position.inMilliseconds
                                          .toDouble(),
                                      min: 0.0,
                                      max: widget.videoControllers[file]!.value
                                          .duration.inMilliseconds
                                          .toDouble(),
                                      onChanged: (value) {
                                        setState(() {
                                          widget.videoControllers[file]!.seekTo(
                                            Duration(
                                                milliseconds: value.toInt()),
                                          );
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDuration(widget
                                      .videoControllers[file]!.value.position),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDuration(widget
                                      .videoControllers[file]!.value.duration),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: file,
                    cacheManager: CustomCacheManager(),
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                // actions: [
                //   IconButton(
                //     icon:
                //         const Icon(Icons.fullscreen_exit, color: Colors.white),
                //     onPressed: () => Navigator.pop(context),
                //   ),
                // ],
              ),
            ),
        ],
      ),
    );
  }
}
