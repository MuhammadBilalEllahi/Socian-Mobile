// import 'package:beyondtheclass/pages/explore/SocietyProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';
// import 'package:record/record.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'widgets/user_info_section.dart';
// import 'widgets/post_type_selector.dart';
// import 'widgets/society_selector.dart';
// import 'widgets/location_section.dart';
// import 'widgets/media_preview.dart';
// import 'widgets/voice_note_section.dart';
// import 'widgets/media_controls.dart';
// import 'dart:async';

// enum PostType { personal, society }

// class CreatePost extends ConsumerStatefulWidget {
//   const CreatePost({
//     super.key,
//   });

//   @override
//   ConsumerState<CreatePost> createState() => _CreatePostState();
// }

// class _CreatePostState extends ConsumerState<CreatePost> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _bodyController = TextEditingController();
//   final _locationSearchController = TextEditingController();

//   PostType _postType = PostType.personal;
//   String? _selectedSocietyId;
//   final List<File> _mediaFiles = [];
//   final Map<String, VideoPlayerController> _videoControllers = {};
//   File? _voiceNote;
//   bool _isRecording = false;
//   bool _isPlaying = false;
//   bool _showMap = false;
//   bool _isVoiceSelected = false;
//   List<double> _waveform = [];
//   late final AudioRecorder _audioRecorder;
//   final _audioPlayer = AudioPlayer();
//   Position? _currentPosition;
//   String? _selectedLocation;
//   Set<Marker> _markers = {};
//   List<String> _searchResults = [];
//   Duration _recordingDuration = Duration.zero;
//   Timer? _recordingTimer;

//   @override
//   void initState() {
//     super.initState();
//     _audioRecorder = AudioRecorder();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _bodyController.dispose();
//     _locationSearchController.dispose();
//     for (var controller in _videoControllers.values) {
//       controller.dispose();
//     }
//     _audioPlayer.dispose();
//     _audioRecorder.dispose();
//     _recordingTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _pickMedia(ImageSource source, bool isVideo) async {
//     try {
//       final picker = ImagePicker();
//       final XFile? pickedFile;

//       if (isVideo) {
//         pickedFile = await picker.pickVideo(source: source);
//       } else {
//         pickedFile = await picker.pickImage(source: source);
//       }

//       if (pickedFile != null) {
//         final file = File(pickedFile.path);
//         setState(() {
//           _mediaFiles.add(file);
//           if (isVideo) {
//             _initializeVideoController(file);
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking media: $e')),
//       );
//     }
//   }

//   Future<void> _initializeVideoController(File file) async {
//     final controller = VideoPlayerController.file(file);
//     await controller.initialize();
//     setState(() {
//       _videoControllers[file.path] = controller;
//     });
//   }

//   Future<void> _selectVoice() async {
//     try {
//       // Stop playback if playing
//       if (_isPlaying) {
//         await _audioPlayer.stop();
//       }

//       // Delete the previous voice note if it exists
//       if (_voiceNote != null) {
//         await _voiceNote!.delete();
//       }

//       setState(() {
//         _mediaFiles.clear();
//         for (var controller in _videoControllers.values) {
//           controller.dispose();
//         }
//         _videoControllers.clear();
//         _showMap = false;
//         _selectedLocation = null;
//         _currentPosition = null;
//         _markers = {};
//         _isVoiceSelected = true;
//         _voiceNote = null;
//         _isPlaying = false;
//         _recordingDuration = Duration.zero;
//         _waveform = [];
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error preparing voice recording: $e')),
//       );
//     }
//   }

//   Future<void> _startRecording() async {
//     try {
//       if (await _audioRecorder.hasPermission()) {
//         final tempDir = await getTemporaryDirectory();
//         final path =
//             '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

//         // Optimize recording configuration for better performance
//         await _audioRecorder.start(
//           const RecordConfig(
//             encoder: AudioEncoder.aacLc,
//             bitRate: 64000, // Reduced from 128000 for better buffer handling
//             sampleRate: 22050, // Reduced from 44100 for better performance
//             numChannels: 1, // Mono recording for smaller file size
//             autoGain: true, // Enable auto gain control
//           ),
//           path: path,
//         );

//         setState(() {
//           _isRecording = true;
//           _waveform = [];
//           _recordingDuration = Duration.zero;
//         });

//         // Start the timer
//         _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//           setState(() {
//             _recordingDuration += const Duration(seconds: 1);
//           });
//         });

//         // Listen to amplitude changes with optimized interval
//         _audioRecorder
//             .onAmplitudeChanged(const Duration(milliseconds: 50))
//             .listen(
//           (amp) {
//             if (_isRecording) {
//               setState(() {
//                 // Normalize and scale the amplitude for better visualization
//                 // amp.current is in dB, typically between -160 and 0
//                 double normalizedValue = (amp.current + 160) / 160;

//                 // Apply non-linear scaling to make the waveform more dynamic
//                 normalizedValue = normalizedValue * normalizedValue;

//                 // Ensure the value is between 0.1 and 1.0 for better visibility
//                 normalizedValue = normalizedValue.clamp(0.1, 1.0);

//                 _waveform.add(normalizedValue);

//                 // Keep only the last 50 values to maintain a consistent width
//                 if (_waveform.length > 50) {
//                   _waveform.removeAt(0);
//                 }
//               });
//             }
//           },
//           onError: (error) {
//             print('Error listening to amplitude: $error');
//           },
//           cancelOnError:
//               true, // Stop listening on error to prevent buffer issues
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error starting recording: $e')),
//       );
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       _recordingTimer?.cancel();

//       // Add a small delay before stopping to ensure all buffers are processed
//       await Future.delayed(const Duration(milliseconds: 100));

//       final path = await _audioRecorder.stop();
//       if (path != null) {
//         setState(() {
//           _voiceNote = File(path);
//           _isRecording = false;
//           _isVoiceSelected = false;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error stopping recording: $e')),
//       );
//     }
//   }

//   Future<void> _playPauseVoiceNote() async {
//     if (_voiceNote == null) return;

//     try {
//       if (_isPlaying) {
//         await _audioPlayer.pause();
//       } else {
//         await _audioPlayer.play(DeviceFileSource(_voiceNote!.path));
//       }
//       setState(() {
//         _isPlaying = !_isPlaying;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error playing voice note: $e')),
//       );
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       final permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         final request = await Geolocator.requestPermission();
//         if (request == LocationPermission.denied) {
//           return;
//         }
//       }

//       final position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _currentPosition = position;
//         _markers = {
//           Marker(
//             markerId: const MarkerId('current_location'),
//             position: LatLng(position.latitude, position.longitude),
//             infoWindow: const InfoWindow(title: 'Current Location'),
//           ),
//         };
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error getting location: $e')),
//       );
//     }
//   }

//   Future<void> _searchLocations(String query) async {
//     // Implement location search using Google Places API
//     // For now, using dummy data
//     setState(() {
//       _searchResults = [
//         'Location 1',
//         'Location 2',
//         'Location 3',
//       ];
//     });
//   }

//   void _selectLocation(String? location) {
//     setState(() {
//       _selectedLocation = location;
//       _searchResults = [];
//     });
//   }

//   void _removeMedia(int index) {
//     final file = _mediaFiles[index];
//     final controller = _videoControllers[file.path];
//     controller?.dispose();
//     _videoControllers.remove(file.path);
//     setState(() {
//       _mediaFiles.removeAt(index);
//     });
//   }

//   void _showFullScreenMedia(int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FullScreenMediaView(
//           mediaFiles: _mediaFiles,
//           initialIndex: index,
//           videoControllers: _videoControllers,
//         ),
//       ),
//     );
//   }

//   Future<void> _deleteVoiceNote() async {
//     try {
//       // Stop playback if playing
//       if (_isPlaying) {
//         await _audioPlayer.stop();
//       }

//       // Delete the file if it exists
//       if (_voiceNote != null) {
//         await _voiceNote!.delete();
//       }

//       setState(() {
//         _voiceNote = null;
//         _isPlaying = false;
//         _recordingDuration = Duration.zero;
//         _waveform = [];
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting voice note: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final societiesState = ref.watch(societiesProvider);
//     final societies = [
//       ...societiesState.subscribedSocieties,
//       ...societiesState.publicSocieties,
//     ];
//     // If you want to deduplicate by id:
//     final uniqueSocieties = {for (var s in societies) s.id: s}.values.toList();

//     // If your SocietySelector expects a list of maps:
//     final societyList = uniqueSocieties
//         .map((s) => {'id': s.id, 'name': s.name} as Map<String, dynamic>)
//         .toList();

//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       appBar: AppBar(
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.close,
//             color: isDark ? Colors.white : Colors.black,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'New Post',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//             letterSpacing: -0.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               if (_formKey.currentState?.validate() ?? false) {
//                 // TODO: Implement post creation
//                 Navigator.pop(context);
//               }
//             },
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               backgroundColor: isDark ? Colors.white : Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'Post',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 color: isDark ? Colors.black : Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             UserInfoSection(
//               postType: _postType,
//               selectedLocation: _selectedLocation,
//               onLocationSelected: _selectLocation,
//               onLocationCleared: () {
//                 setState(() {
//                   _selectedLocation = null;
//                   _currentPosition = null;
//                   _markers = {};
//                   _showMap = false;
//                 });
//               },
//             ),
//             PostTypeSelector(
//               selectedType: _postType,
//               onTypeChanged: (type) {
//                 setState(() {
//                   _postType = type;
//                   _selectedSocietyId = null;
//                   if (type == PostType.personal) {
//                     _showMap = false;
//                   }
//                 });
//               },
//             ),
//             if (_postType == PostType.society)
//               SocietySelector(
//                 societies: societyList,
//                 selectedSocietyId: _selectedSocietyId,
//                 onSocietySelected: (id) {
//                   setState(() {
//                     _selectedSocietyId = id;
//                   });
//                 },
//               ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     controller: _titleController,
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: -0.5,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'What\'s on your mind?',
//                       border: InputBorder.none,
//                       hintStyle: theme.textTheme.titleLarge?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.5),
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     maxLines: null,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a title';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _bodyController,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       letterSpacing: -0.2,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Add more details...',
//                       border: InputBorder.none,
//                       hintStyle: theme.textTheme.bodyLarge?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.5),
//                         letterSpacing: -0.2,
//                       ),
//                     ),
//                     maxLines: null,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter some content';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             if (_mediaFiles.isNotEmpty)
//               MediaPreview(
//                 mediaFiles: _mediaFiles,
//                 videoControllers: _videoControllers,
//                 onMediaTap: _showFullScreenMedia,
//                 onMediaRemove: _removeMedia,
//               ),
//             MediaControls(
//               onImagePick: () => _pickMedia(ImageSource.gallery, false),
//               onVideoPick: () => _pickMedia(ImageSource.gallery, true),
//               onVoiceNoteStart:
//                   _isVoiceSelected ? _startRecording : _selectVoice,
//               onVoiceNoteStop: _stopRecording,
//               isRecording: _isRecording,
//               showMap: _showMap,
//               onMapToggle: () {
//                 if (_postType == PostType.society) {
//                   setState(() {
//                     if (!_showMap) {
//                       // Clear media when enabling map
//                       _mediaFiles.clear();
//                       for (var controller in _videoControllers.values) {
//                         controller.dispose();
//                       }
//                       _videoControllers.clear();
//                       _voiceNote = null;
//                       _isPlaying = false;
//                       _isVoiceSelected = false;
//                     }
//                     _showMap = !_showMap;
//                   });
//                 }
//               },
//               postType: _postType,
//               mediaFiles: _mediaFiles,
//               voiceNote: _voiceNote,
//               isVoiceSelected: _isVoiceSelected,
//             ),
//             if (_voiceNote != null || _isRecording)
//               VoiceNoteSection(
//                 isRecording: _isRecording,
//                 isPlaying: _isPlaying,
//                 voiceNote: _voiceNote,
//                 waveform: _waveform,
//                 onPlayPause: _playPauseVoiceNote,
//                 onDelete: _deleteVoiceNote,
//                 recordingDuration: _recordingDuration,
//               ),
//             if (_showMap)
//               LocationSection(
//                 postType: _postType,
//                 selectedLocation: _selectedLocation,
//                 currentPosition: _currentPosition,
//                 onLocationSelected: _selectLocation,
//                 onLocationCleared: () {
//                   setState(() {
//                     _selectedLocation = null;
//                     _currentPosition = null;
//                     _markers = {};
//                     _showMap = false;
//                   });
//                 },
//                 onSearchQueryChanged: _searchLocations,
//                 onMapLocationSelected: (position) {
//                   setState(() {
//                     _currentPosition = position;
//                     _markers = {
//                       Marker(
//                         markerId: const MarkerId('selected_location'),
//                         position: LatLng(
//                           position!.latitude,
//                           position.longitude,
//                         ),
//                         infoWindow:
//                             const InfoWindow(title: 'Selected Location'),
//                       ),
//                     };
//                   });
//                 },
//               ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class WaveformPainter extends CustomPainter {
//   final List<double> waveform;
//   final Color color;

//   WaveformPainter({
//     required this.waveform,
//     required this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = 2
//       ..strokeCap = StrokeCap.round;

//     final width = size.width;
//     final height = size.height;
//     final barWidth = width / waveform.length;

//     for (var i = 0; i < waveform.length; i++) {
//       final x = i * barWidth;
//       final barHeight = waveform[i] * height;
//       final y = (height - barHeight) / 2;
//       canvas.drawLine(
//         Offset(x, y),
//         Offset(x, y + barHeight),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(WaveformPainter oldDelegate) {
//     return waveform != oldDelegate.waveform;
//   }
// }

// class FullScreenMediaView extends StatefulWidget {
//   final List<File> mediaFiles;
//   final Map<String, VideoPlayerController> videoControllers;
//   final int initialIndex;

//   const FullScreenMediaView({
//     super.key,
//     required this.mediaFiles,
//     required this.videoControllers,
//     required this.initialIndex,
//   });

//   @override
//   State<FullScreenMediaView> createState() => _FullScreenMediaViewState();
// }

// class _FullScreenMediaViewState extends State<FullScreenMediaView> {
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.mediaFiles.length,
//         itemBuilder: (context, index) {
//           final file = widget.mediaFiles[index];
//           final isImage = file.path.toLowerCase().endsWith('.jpg') ||
//               file.path.toLowerCase().endsWith('.png') ||
//               file.path.toLowerCase().endsWith('.jpeg');
//           final isVideo = widget.videoControllers.containsKey(file.path);

//           if (isVideo) {
//             return Stack(
//               alignment: Alignment.center,
//               children: [
//                 AspectRatio(
//                   aspectRatio:
//                       widget.videoControllers[file.path]!.value.aspectRatio,
//                   child: VideoPlayer(widget.videoControllers[file.path]!),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                     widget.videoControllers[file.path]!.value.isPlaying
//                         ? Icons.pause
//                         : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 48,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       if (widget.videoControllers[file.path]!.value.isPlaying) {
//                         widget.videoControllers[file.path]!.pause();
//                       } else {
//                         widget.videoControllers[file.path]!.play();
//                       }
//                     });
//                   },
//                 ),
//               ],
//             );
//           }

//           return Center(
//             child: isImage
//                 ? Image.file(
//                     file,
//                     fit: BoxFit.contain,
//                   )
//                 : Icon(
//                     Icons.video_library,
//                     size: 64,
//                     color: theme.colorScheme.primary,
//                   ),
//           );
//         },
//       ),
//     );
//   }
// }




import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/pages/explore/SocietyProvider.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'widgets/user_info_section.dart';
import 'widgets/post_type_selector.dart';
import 'widgets/society_selector.dart';
import 'widgets/location_section.dart';
import 'widgets/media_preview.dart';
import 'widgets/voice_note_section.dart';
import 'dart:async';

enum PostType { personal, society }

class CreatePost extends ConsumerStatefulWidget {
  const CreatePost({super.key});

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
  bool _isLoading = false;
  List<double> _waveform = [];
  late final AudioRecorder _audioRecorder;
  final _audioPlayer = AudioPlayer();
  Position? _currentPosition;
  String? _selectedLocation;
  Set<Marker> _markers = {};
  List<String> _searchResults = [];
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _apiClient = ApiClient();
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

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile =
          isVideo ? await picker.pickVideo(source: source) : await picker.pickImage(source: source);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing voice recording: $e')),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
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
        _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 50)).listen(
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
            print('Error listening to amplitude: $error');
          },
          cancelOnError: true,
        );
      }
    } catch (e) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _searchLocations(String query) async {
    setState(() {
      _searchResults = [
        'Location 1',
        'Location 2',
        'Location 3',
      ];
    });
  }

  void _selectLocation(String? location) {
    setState(() {
      _selectedLocation = location;
      _searchResults = [];
    });
  }

  void _removeMedia(int index) {
    final file = _mediaFiles[index];
    final controller = _videoControllers[file.path];
    controller?.dispose();
    _videoControllers.remove(file.path);
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  void _showFullScreenMedia(int index) {
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
      final token = await SecureStorageService.instance.getToken();
      debugPrint('Token: $token');
      debugPrint('UserId: $userId');
      debugPrint('User: $user');

      if (userId == null) {
        throw Exception('User ID is null. Check authProvider configuration.');
      }

      // Extract campusId for references.campusOrigin
      String? campusId;
      if (_postType == PostType.personal) {
        final university = user?['university'];
        campusId = university?['campusId']?['_id']?.toString();

        if (campusId == null) {
          throw Exception('Campus ID is missing from user data.');
        }
      }

      final data = <String, dynamic>{
        'title': _titleController.text,
        'author': userId,
        if (_bodyController.text.isNotEmpty) 'body': _bodyController.text,
        if (_postType == PostType.society && _selectedSocietyId != null)
          'societyId': _selectedSocietyId,
        if (_postType == PostType.personal) 'references[campusOrigin]': campusId,
      };

      // Add media files (images/videos)
      if (_mediaFiles.isNotEmpty) {
        data['file'] = await Future.wait(
          _mediaFiles.map((file) async => await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              )),
        );
      }

      // Add voice note
      if (_voiceNote != null) {
        data['file'] = [
          ...(data['file'] ?? []),
          await MultipartFile.fromFile(
            _voiceNote!.path,
            filename: _voiceNote!.path.split('/').last,
          ),
        ];
      }

      // Choose endpoint based on post type
      final endpoint =
          _postType == PostType.society ? '/api/posts/create' : '/api/posts/create-indiv';
      final fullUrl = '${ApiConstants.baseUrl}$endpoint';
      debugPrint('Request URL: $fullUrl');
      debugPrint('Request Data: $data');

      // Send request using ApiClient
      final response = await _apiClient.postFormData(endpoint, data);
      debugPrint('Response: $response');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
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
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.04;
    final spacing = screenSize.height * 0.02;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
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
          'New Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            fontSize: screenSize.width * 0.05,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: padding * 2,
                  vertical: spacing,
                ),
                backgroundColor: isDark ? Colors.white : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: screenSize.width * 0.04,
                      height: screenSize.width * 0.04,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    )
                  : Text(
                      'Post',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(padding),
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: UserInfoSection(
                      postType: _postType,
                      selectedLocation: _selectedLocation,
                      onLocationSelected: _selectLocation,
                      onLocationCleared: () {
                        setState(() {
                          _selectedLocation = null;
                          _currentPosition = null;
                          _markers = {};
                          _showMap = false;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: PostTypeSelector(
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
                  ),
                ),
                SizedBox(height: spacing),
                if (_postType == PostType.society)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: SocietySelector(
                        societies: societyList,
                        selectedSocietyId: _selectedSocietyId,
                        onSocietySelected: (id) {
                          setState(() {
                            _selectedSocietyId = id;
                          });
                        },
                      ),
                    ),
                  ),
                if (_postType == PostType.society) SizedBox(height: spacing),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            fontSize: screenSize.width * 0.05,
                          ),
                          decoration: InputDecoration(
                            hintText: 'What\'s on your mind?',
                            hintStyle: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white : Colors.black,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: spacing),
                        TextFormField(
                          controller: _bodyController,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            letterSpacing: -0.2,
                            fontSize: screenSize.width * 0.04,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add more details...',
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              letterSpacing: -0.2,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white : Colors.black,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if ((value == null || value.isEmpty) && _mediaFiles.isEmpty && _voiceNote == null) {
                              return 'Please enter content or add media';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                if (_mediaFiles.isNotEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: MediaPreview(
                        mediaFiles: _mediaFiles,
                        videoControllers: _videoControllers,
                        onMediaTap: _showFullScreenMedia,
                        onMediaRemove: _removeMedia,
                      ),
                    ),
                  ),
                if (_mediaFiles.isNotEmpty) SizedBox(height: spacing),
                Card(
                  // elevation: ResultSet(
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Wrap(
                      spacing: padding,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildControlButton(
                          icon: Icons.image,
                          label: 'Image',
                          onTap: () => _pickMedia(ImageSource.gallery, false),
                          screenWidth: screenSize.width,
                        ),
                        _buildControlButton(
                          icon: Icons.videocam,
                          label: 'Video',
                          onTap: () => _pickMedia(ImageSource.gallery, true),
                          screenWidth: screenSize.width,
                        ),
                        _buildControlButton(
                          icon: _isRecording ? Icons.stop : Icons.mic,
                          label: _isRecording ? 'Stop' : 'Voice',
                          onTap: _isVoiceSelected
                              ? _startRecording
                              : _isRecording
                                  ? _stopRecording
                                  : _selectVoice,
                          screenWidth: screenSize.width,
                        ),
                        if (_postType == PostType.society)
                          _buildControlButton(
                            icon: _showMap ? Icons.map_outlined : Icons.map,
                            label: 'Location',
                            onTap: () {
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
                            },
                            screenWidth: screenSize.width,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                if (_voiceNote != null || _isRecording)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: VoiceNoteSection(
                        isRecording: _isRecording,
                        isPlaying: _isPlaying,
                        voiceNote: _voiceNote,
                        waveform: _waveform,
                        onPlayPause: _playPauseVoiceNote,
                        onDelete: _deleteVoiceNote,
                        recordingDuration: _recordingDuration,
                      ),
                    ),
                  ),
                if (_voiceNote != null || _isRecording) SizedBox(height: spacing),
                if (_showMap)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: LocationSection(
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
                                infoWindow: const InfoWindow(title: 'Selected Location'),
                              ),
                            };
                          });
                        },
                      ),
                    ),
                  ),
                SizedBox(height: spacing),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.2,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: screenWidth * 0.06,
              color: isDark ? Colors.white : Colors.black,
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveform;
  final Color color;

  WaveformPainter({
    required this.waveform,
    required this.color,
  });

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
    final screenSize = MediaQuery.of(context).size;

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
                  aspectRatio: widget.videoControllers[file.path]!.value.aspectRatio,
                  child: VideoPlayer(widget.videoControllers[file.path]!),
                ),
                IconButton(
                  icon: Icon(
                    widget.videoControllers[file.path]!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: screenSize.width * 0.12,
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
                    size: screenSize.width * 0.16,
                    color: theme.colorScheme.primary,
                  ),
          );
        },
      ),
    );
  }
}