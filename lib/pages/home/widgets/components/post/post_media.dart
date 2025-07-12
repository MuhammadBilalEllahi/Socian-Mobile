import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/profile/ProfilePage.dart';
import 'package:socian/shared/services/api_client.dart';

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
  final dynamic post;
  final int flairType;

  const PostMedia({
    super.key,
    required this.media,
    required this.post,
    required this.flairType,
  });

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Preload adjacent images after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _preloadAdjacentImages(0);
      }
    });
  }

  void _preloadAdjacentImages(int currentIndex) {
    if (widget.media == null) return;

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

  @override
  void dispose() {
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
                  final mediaType = item['type'] ?? '';

                  if (mediaType.startsWith('image/')) {
                    return PostImageMedia(
                      imageUrl: item['url'],
                      post: widget.post,
                      flairType: widget.flairType,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenMediaView(
                              mediaFiles: [item['url']],
                              initialIndex: 0,
                              videoControllers: const {},
                              isImage: true,
                              post: widget.post,
                              flairType: widget.flairType,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (mediaType.startsWith('video/')) {
                    return PostVideoMedia(
                      videoUrl: item['url'],
                      post: widget.post,
                      flairType: widget.flairType,
                    );
                  } else if (mediaType.startsWith('audio/')) {
                    return PostAudioMedia(
                      audioUrl: item['url'],
                    );
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

  @override
  bool get wantKeepAlive => true;
}

class PostImageMedia extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;
  final dynamic post;
  final int flairType;

  const PostImageMedia({
    super.key,
    required this.imageUrl,
    this.onTap,
    required this.post,
    required this.flairType,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          child: ClipRRect(
            // borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
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
}

class PostVideoMedia extends StatefulWidget {
  final String videoUrl;
  final dynamic post;
  final int flairType;

  const PostVideoMedia({
    super.key,
    required this.videoUrl,
    required this.post,
    required this.flairType,
  });

  @override
  State<PostVideoMedia> createState() => _PostVideoMediaState();
}

class _PostVideoMediaState extends State<PostVideoMedia> {
  CachedVideoPlayerPlusController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.videoUrl),
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

  @override
  void dispose() {
    _videoController?.removeListener(() {
      if (mounted) setState(() {});
    });
    _videoController?.dispose();
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
                                post: widget.post,
                                flairType: widget.flairType,
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
}

class PostAudioMedia extends StatefulWidget {
  final String audioUrl;

  const PostAudioMedia({
    super.key,
    required this.audioUrl,
  });

  @override
  State<PostAudioMedia> createState() => _PostAudioMediaState();
}

class _PostAudioMediaState extends State<PostAudioMedia>
    with SingleTickerProviderStateMixin {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late AnimationController _waveformController;
  final List<double> _waveform =
      List.generate(50, (index) => math.Random().nextDouble() * 0.5 + 0.5);

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  void _initializeAudio() {
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
    _audioPlayer!.setSourceUrl(widget.audioUrl);
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
    _audioPlayer?.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

class FullScreenMediaView extends ConsumerStatefulWidget {
  final List<String> mediaFiles;
  final Map<String, CachedVideoPlayerPlusController> videoControllers;
  final int initialIndex;
  final bool isImage;
  final dynamic post;
  final int flairType;

  const FullScreenMediaView({
    super.key,
    required this.mediaFiles,
    required this.videoControllers,
    required this.initialIndex,
    required this.isImage,
    required this.post,
    required this.flairType,
  });

  @override
  ConsumerState<FullScreenMediaView> createState() =>
      _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends ConsumerState<FullScreenMediaView> {
  late PageController _pageController;
  bool _showControls = true;
  bool isLiked = false;
  bool isDisliked = false;
  bool isVoting = false;
  final _apiClient = ApiClient();

  late final authUser;
  late final currentUserId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    // Add listeners to all video controllers
    for (var controller in widget.videoControllers.values) {
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    }

    // Initialize voting state
    authUser = ref.read(authProvider).user;
    currentUserId = authUser?['_id'];

    final String? yourVoteStatus =
        widget.post['voteId']?['userVotes']?[currentUserId] as String?;
    isLiked = yourVoteStatus == 'upvote';
    isDisliked = yourVoteStatus == 'downvote';
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Remove listeners from all video controllers
    for (var controller in widget.videoControllers.values) {
      controller.removeListener(() {
        if (mounted) setState(() {});
      });
    }
    super.dispose();
  }

  Future<void> _votePost(String voteType) async {
    if (isVoting) return;

    // Store previous state for rollback in case of error
    final previousUpVotes = widget.post['voteId']['upVotesCount'] as int;
    final previousDownVotes = widget.post['voteId']['downVotesCount'] as int;
    final previousIsLiked = isLiked;
    final previousIsDisliked = isDisliked;

    // Optimistically update UI
    setState(() {
      isVoting = true;

      // Update vote counts and like/dislike state
      if (voteType == 'upvote') {
        if (isLiked) {
          // Undo like
          widget.post['voteId']['upVotesCount']--;
          isLiked = false;
        } else {
          // Apply like
          widget.post['voteId']['upVotesCount']++;
          if (isDisliked) {
            widget.post['voteId']['downVotesCount']--;
            isDisliked = false;
          }
          isLiked = true;
        }
      } else if (voteType == 'downvote') {
        if (isDisliked) {
          // Undo dislike
          widget.post['voteId']['downVotesCount']--;
          isDisliked = false;
        } else {
          // Apply dislike
          widget.post['voteId']['downVotesCount']++;
          if (isLiked) {
            widget.post['voteId']['upVotesCount']--;
            isLiked = false;
          }
          isDisliked = true;
        }
      }
    });

    try {
      final response = await _apiClient.post('/api/posts/vote-post', {
        'postId': widget.post['_id'],
        'voteType': voteType,
      });

      // Sync with server response
      setState(() {
        widget.post['voteId']['upVotesCount'] = response['upVotesCount'];
        widget.post['voteId']['downVotesCount'] = response['downVotesCount'];

        if (response['noneSelected'] == true) {
          isLiked = false;
          isDisliked = false;
        } else {
          isLiked = voteType == 'upvote' && response['noneSelected'] != true;
          isDisliked =
              voteType == 'downvote' && response['noneSelected'] != true;
        }
      });
    } catch (e) {
      // Revert optimistic updates on error
      setState(() {
        widget.post['voteId']['upVotesCount'] = previousUpVotes;
        widget.post['voteId']['downVotesCount'] = previousDownVotes;
        isLiked = previousIsLiked;
        isDisliked = previousIsDisliked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: $e')),
      );
    } finally {
      setState(() {
        isVoting = false;
      });
    }
  }

  void _showDescriptionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.post['body'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionWithReadMore(String text) {
    // Simple approach: if text is longer than 120 characters, show "read more..."
    if (text.length > 120) {
      return GestureDetector(
        onTap: _showDescriptionBottomSheet,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: '${text.substring(0, 120)}...',
              ),
              const TextSpan(
                text: ' read more...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      // Text is short, show as is
      return Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        maxLines: 2,
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.post['author'] ?? {};
    final createdAt = DateTime.parse(widget.post['createdAt']);
    final formattedDate = DateFormat('MMM d, y').format(createdAt);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media content
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
                            child: const Row(
                              children: [
                                // ... existing video controls ...
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
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: FittedBox(
                    fit: BoxFit.contain,
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
                ),
              );
            },
          ),

          // Top controls
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom post info with right-side action buttons
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Post info section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // User info
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: author['_id'] != null &&
                                            author['username']?.isNotEmpty ==
                                                true
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage(
                                                        userId: author['_id']),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey[800],
                                      backgroundImage: author['profile'] != null
                                          ? NetworkImage(author['profile']
                                                  ['picture'] ??
                                              '')
                                          : const AssetImage(
                                                  'assets/default_profile_picture.png')
                                              as ImageProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          author['name'] ?? '{Deleted}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '@${author['username'] ?? ''} • $formattedDate',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Title
                              if (widget.post['title'] != null &&
                                  widget.post['title'].isNotEmpty)
                                Text(
                                  widget.post['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              // Description with read more
                              if (widget.post['body'] != null &&
                                  widget.post['body'].isNotEmpty)
                                _buildDescriptionWithReadMore(
                                    widget.post['body']),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Action buttons on the right
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Like button
                            GestureDetector(
                              onTap: () => _votePost('upvote'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isLiked
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_outline,
                                      color:
                                          isLiked ? Colors.red : Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.post['voteId']?['upVotesCount'] ?? 0}',
                                      style: TextStyle(
                                        color:
                                            isLiked ? Colors.red : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Dislike button
                            GestureDetector(
                              onTap: () => _votePost('downvote'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDisliked
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isDisliked
                                          ? Icons.thumb_down
                                          : Icons.thumb_down_outlined,
                                      color: isDisliked
                                          ? Colors.blue
                                          : Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.post['voteId']?['downVotesCount'] ?? 0}',
                                      style: TextStyle(
                                        color: isDisliked
                                            ? Colors.blue
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Comment button
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                // Navigate to post detail page for comments
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${widget.post['commentsCount'] ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
