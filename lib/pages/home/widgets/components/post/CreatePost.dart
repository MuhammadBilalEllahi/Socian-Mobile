import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:socian/core/utils/constants.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';
import 'package:socian/pages/explore/SocietyProvider.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:video_player/video_player.dart';

import 'widgets/location_section.dart';
import 'widgets/media_controls.dart';
import 'widgets/media_preview.dart';
import 'widgets/post_type_selector.dart';
import 'widgets/society_selector.dart';
import 'widgets/user_info_section.dart';
import 'widgets/voice_note_section.dart';

enum PostType { personal, society }

class CreatePost extends ConsumerStatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? postData;

  const CreatePost({
    super.key,
    this.isEditing = false,
    this.postData,
  });

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _locationSearchController = TextEditingController();

  PostType _postType = PostType.personal;
  String? _selectedSocietyId;
  final List<File> _mediaFiles = [];
  final Map<String, VideoPlayerController> _videoControllers = {};
  File? _voiceNote;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _showMap = false;
  bool _isVoiceSelected = false;
  List<double> _waveform = [];
  late final AudioRecorder _audioRecorder;
  final _audioPlayer = AudioPlayer();
  Position? _currentPosition;
  String? _selectedLocation;
  Set<Marker> _markers = {};
  List<String> _searchResults = [];
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  bool _isLoading = false;
  List<Map<String, dynamic>> _existingMedia = [];

  final _apiClient = ApiClient(); // Initialize ApiClient

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();

    if (widget.isEditing && widget.postData != null) {
      _titleController.text = widget.postData!['title'] ?? '';
      _bodyController.text = widget.postData!['body'] ?? '';

      // Set post type
      if (widget.postData!['society'] != null) {
        _postType = PostType.society;
        _selectedSocietyId = widget.postData!['society']['_id'];
      }

      // Handle existing media
      if (widget.postData!['media'] != null) {
        setState(() {
          _existingMedia =
              List<Map<String, dynamic>>.from(widget.postData!['media']);
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _locationSearchController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickMultipleMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'png', 'mp4', 'mov'], // add more if needed
          withData: true);

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _mediaFiles.addAll(result.files.map((f) => File(f.path!)));
          for (var file in result.files) {
            if (file.extension == 'mp4' || file.extension == 'mov') {
              _initializeVideoController(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking multiple files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking multiple files: $e')),
      );
    }
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile;

      if (isVideo) {
        pickedFile = await picker.pickVideo(source: source);
      } else {
        pickedFile = await picker.pickImage(source: source);
      }

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _mediaFiles.add(file);
          if (isVideo) {
            _initializeVideoController(file);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking media: $e')),
      );
    }
  }

  Future<void> _initializeVideoController(File file) async {
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    setState(() {
      _videoControllers[file.path] = controller;
    });
  }

  Future<void> _selectVoice() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }
      if (_voiceNote != null) {
        await _voiceNote!.delete();
      }
      setState(() {
        _mediaFiles.clear();
        for (var controller in _videoControllers.values) {
          controller.dispose();
        }
        _videoControllers.clear();
        _showMap = false;
        _selectedLocation = null;
        _currentPosition = null;
        _markers = {};
        _isVoiceSelected = true;
        _voiceNote = null;
        _isPlaying = false;
        _recordingDuration = Duration.zero;
        _waveform = [];
      });
    } catch (e) {
      debugPrint('Error preparing voice recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing voice recording: $e')),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 64000,
            sampleRate: 22050,
            numChannels: 1,
            autoGain: true,
          ),
          path: path,
        );
        setState(() {
          _isRecording = true;
          _waveform = [];
          _recordingDuration = Duration.zero;
        });
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
        });
        _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 50))
            .listen(
          (amp) {
            if (_isRecording) {
              setState(() {
                double normalizedValue = (amp.current + 160) / 160;
                normalizedValue = normalizedValue * normalizedValue;
                normalizedValue = normalizedValue.clamp(0.1, 1.0);
                _waveform.add(normalizedValue);
                if (_waveform.length > 50) {
                  _waveform.removeAt(0);
                }
              });
            }
          },
          onError: (error) {
            debugPrint('Error listening to amplitude: $error');
          },
          cancelOnError: true,
        );
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      await Future.delayed(const Duration(milliseconds: 100));
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _voiceNote = File(path);
          _isRecording = false;
          _isVoiceSelected = false;
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  Future<void> _playPauseVoiceNote() async {
    if (_voiceNote == null) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_voiceNote!.path));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      debugPrint('Error playing voice note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing voice note: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied) {
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        };
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _searchLocations(String query) async {
    setState(() {
      _searchResults = ['Location 1', 'Location 2', 'Location 3'];
    });
  }

  void _selectLocation(String? location) {
    setState(() {
      _selectedLocation = location;
      _searchResults = [];
    });
  }

  void _removeMedia(int index, bool isExistingMedia) {
    log('isExistingMedia: $isExistingMedia  index: $index');
    if (isExistingMedia) {
      final existingMediaIndex = index;
      setState(() {
        _existingMedia.removeAt(existingMediaIndex);
      });
    } else {
      final newMediaIndex = index - _existingMedia.length;
      final file = _mediaFiles[newMediaIndex];
      final controller = _videoControllers[file.path];
      controller?.dispose();
      _videoControllers.remove(file.path);
      setState(() {
        _mediaFiles.removeAt(newMediaIndex);
      });
    }
  }

  void _showFullScreenMedia(int index, bool isExistingMedia) {
    if (isExistingMedia) {
      // Handle showing full screen for existing media
      final mediaItem = _existingMedia[index];
      if (mediaItem['type']?.startsWith('image/') ?? false) {
        // Show image in full screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: CachedNetworkImage(
                  imageUrl: mediaItem['url'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      } else if (mediaItem['type']?.startsWith('video/') ?? false) {
        // Show video in full screen
        final controller = VideoPlayerController.network(mediaItem['url']);
        controller.initialize().then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      controller.dispose();
                      Navigator.pop(context);
                    },
                  ),
                ),
                body: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),
          );
        });
      }
    } else {
      // Handle showing full screen for new media files
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenMediaView(
            mediaFiles: _mediaFiles,
            initialIndex: index,
            videoControllers: _videoControllers,
          ),
        ),
      );
    }
  }

  Future<void> _deleteVoiceNote() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }
      if (_voiceNote != null) {
        await _voiceNote!.delete();
      }
      setState(() {
        _voiceNote = null;
        _isPlaying = false;
        _recordingDuration = Duration.zero;
        _waveform = [];
      });
    } catch (e) {
      debugPrint('Error deleting voice note: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting voice note: $e')),
      );
    }
  }

  Future<void> _createPost() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = ref.read(authProvider).user;
        final userId = user?['_id'];
        debugPrint('User: $user');
        debugPrint('UserId: $userId');

        if (userId == null) {
          throw Exception('User ID is null. Check authProvider configuration.');
        }

        final data = <String, dynamic>{
          'title': _titleController.text,
          'author': userId,
          if (_bodyController.text.isNotEmpty) 'body': _bodyController.text,
          if (_postType == PostType.society && _selectedSocietyId != null)
            'societyId': _selectedSocietyId,
        };

        // Handle media list (both existing and new)
        if (widget.isEditing &&
            widget.postData != null &&
            widget.postData!['media'] != null) {
          // For editing, send the updated media list
          data['mediaList'] = _existingMedia;
        } else if (!widget.isEditing && _existingMedia.isNotEmpty) {
          // For new posts with existing media
          data['mediaList'] = _existingMedia;
        }

        // Handle new media files
        if (_mediaFiles.isNotEmpty) {
          data['file'] = await Future.wait(
            _mediaFiles.map((file) async {
              final fileType =
                  file.path.toLowerCase().endsWith('.mp4') ? 'video' : 'image';
              return MultipartFile.fromFile(
                file.path,
                filename:
                    '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}',
                contentType: MediaType.parse(
                    fileType == 'video' ? 'video/mp4' : 'image/jpeg'),
              );
            }),
          );
        }

        // Handle voice note
        if (_voiceNote != null) {
          final voiceFile = await MultipartFile.fromFile(
            _voiceNote!.path,
            filename: '${DateTime.now().millisecondsSinceEpoch}_voice.m4a',
            contentType: MediaType.parse('audio/m4a'),
          );

          if (data['file'] != null) {
            data['file'] = [...data['file'], voiceFile];
          } else {
            data['file'] = [voiceFile];
          }
        }

        String endpoint;
        if (widget.isEditing) {
          endpoint = '/api/posts/post/edit/${widget.postData!['_id']}';
        } else {
          endpoint = _postType == PostType.society
              ? '/api/posts/create'
              : '/api/posts/create-indiv';
        }

        debugPrint('Request URL: ${ApiConstants.baseUrl}$endpoint');
        debugPrint('Request Data: $data');

        final response = widget.isEditing
            ? await _apiClient.putFormData(endpoint, data)
            : await _apiClient.postFormData(endpoint, data);

        debugPrint('Response: $response');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ??
                  (widget.isEditing
                      ? 'Post updated successfully'
                      : 'Post created successfully'))),
        );
        Navigator.pop(context);
      } catch (e) {
        debugPrint(
            'Error ${widget.isEditing ? 'updating' : 'creating'} post: $e');
        if (e is DioException) {
          debugPrint('Dio Error: ${e.response?.data}');
          debugPrint('Status Code: ${e.response?.statusCode}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error ${widget.isEditing ? 'updating' : 'creating'} post: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final societiesState = ref.watch(societiesProvider);
    final societies = [
      ...societiesState.subscribedSocieties,
      ...societiesState.publicSocieties,
    ];
    final uniqueSocieties = {for (var s in societies) s.id: s}.values.toList();
    final societyList = uniqueSocieties
        .map((s) => {'id': s.id, 'name': s.name} as Map<String, dynamic>)
        .toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      // backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Update Post' : 'New Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: isDark ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    widget.isEditing ? 'Update' : 'Post',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserInfoSection(
              postType: _postType,
              selectedLocation: _selectedLocation,
              // onLocationSelected: _selectLocation,
            //   onLocationCleared: () {
            //     setState(() {
            //       _selectedLocation = null;
            //       _currentPosition = null;
            //       _markers = {};
            //       _showMap = false;
            //     });
            //   },
            ),
            PostTypeSelector(
              selectedType: _postType,
              onTypeChanged: (type) {
                setState(() {
                  _postType = type;
                  _selectedSocietyId = null;
                  if (type == PostType.personal) {
                    _showMap = false;
                  }
                });
              },
            ),
            if (_postType == PostType.society)
              SocietySelector(
                societies: societyList,
                selectedSocietyId: _selectedSocietyId,
                onSocietySelected: (id) {
                  setState(() {
                    _selectedSocietyId = id;
                  });
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bodyController,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      letterSpacing: -0.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add more details...',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        letterSpacing: -0.2,
                      ),
                    ),
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            if (_mediaFiles.isNotEmpty || _existingMedia.isNotEmpty)
              MediaPreview(
                existingMedia: _existingMedia,
                mediaFiles: _mediaFiles,
                videoControllers: _videoControllers,
                onMediaTap: _showFullScreenMedia,
                onMediaRemove: _removeMedia,
              ),
            MediaControls(
              onImagePick: () => _pickMultipleMedia(),
              onVideoPick: () => _pickMedia(ImageSource.gallery, true),
              onVoiceNoteStart:
                  _isVoiceSelected ? _startRecording : _selectVoice,
              onVoiceNoteStop: _stopRecording,
              isRecording: _isRecording,
              showMap: _showMap,
              onMapToggle: () {
                if (_postType == PostType.society) {
                  setState(() {
                    if (!_showMap) {
                      _mediaFiles.clear();
                      for (var controller in _videoControllers.values) {
                        controller.dispose();
                      }
                      _videoControllers.clear();
                      _voiceNote = null;
                      _isPlaying = false;
                      _isVoiceSelected = false;
                    }
                    _showMap = !_showMap;
                  });
                }
              },
              postType: _postType,
              mediaFiles: _mediaFiles,
              voiceNote: _voiceNote,
              isVoiceSelected: _isVoiceSelected,
            ),
            if (_voiceNote != null || _isRecording)
              VoiceNoteSection(
                isRecording: _isRecording,
                isPlaying: _isPlaying,
                voiceNote: _voiceNote,
                waveform: _waveform,
                onPlayPause: _playPauseVoiceNote,
                onDelete: _deleteVoiceNote,
                recordingDuration: _recordingDuration,
              ),
            if (_showMap)
              LocationSection(
                postType: _postType,
                selectedLocation: _selectedLocation,
                currentPosition: _currentPosition,
                onLocationSelected: _selectLocation,
                onLocationCleared: () {
                  setState(() {
                    _selectedLocation = null;
                    _currentPosition = null;
                    _markers = {};
                    _showMap = false;
                  });
                },
                onSearchQueryChanged: _searchLocations,
                onMapLocationSelected: (position) {
                  setState(() {
                    _currentPosition = position;
                    _markers = {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: LatLng(
                          position!.latitude,
                          position.longitude,
                        ),
                        infoWindow:
                            const InfoWindow(title: 'Selected Location'),
                      ),
                    };
                  });
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;

  WaveformPainter({required this.waveform, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final barWidth = width / waveform.length;

    for (var i = 0; i < waveform.length; i++) {
      final x = i * barWidth;
      final barHeight = waveform[i] * height;
      final y = (height - barHeight) / 2;
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return waveform != oldDelegate.waveform;
  }
}

class FullScreenMediaView extends StatefulWidget {
  final List<File> mediaFiles;
  final Map<String, VideoPlayerController> videoControllers;
  final int initialIndex;

  const FullScreenMediaView({
    super.key,
    required this.mediaFiles,
    required this.videoControllers,
    required this.initialIndex,
  });

  @override
  State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
}

class _FullScreenMediaViewState extends State<FullScreenMediaView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaFiles.length,
        itemBuilder: (context, index) {
          final file = widget.mediaFiles[index];
          final isImage = file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.png') ||
              file.path.toLowerCase().endsWith('.jpeg');
          final isVideo = widget.videoControllers.containsKey(file.path);

          if (isVideo) {
            return Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio:
                      widget.videoControllers[file.path]!.value.aspectRatio,
                  child: VideoPlayer(widget.videoControllers[file.path]!),
                ),
                IconButton(
                  icon: Icon(
                    widget.videoControllers[file.path]!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                  onPressed: () {
                    setState(() {
                      if (widget.videoControllers[file.path]!.value.isPlaying) {
                        widget.videoControllers[file.path]!.pause();
                      } else {
                        widget.videoControllers[file.path]!.play();
                      }
                    });
                  },
                ),
              ],
            );
          }

          return Center(
            child: isImage
                ? Image.file(
                    file,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    Icons.video_library,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
          );
        },
      ),
    );
  }
}
