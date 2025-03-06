import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'dart:io';
import 'dart:math' as math;

enum PostType { personal, society }

class CreatePost extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> societies; // List of societies with id and name

  const CreatePost({
    super.key,
    required this.societies,
  });

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _locationController = TextEditingController();
  
  final List<File> _selectedMedia = [];
  File? _voiceNote;
  Position? _currentPosition;
  bool _isRecording = false;
  final _audioRecorder = AudioRecorder();
  PostType _postType = PostType.personal;
  String? _selectedSocietyId;
  List<double> _audioWaveform = [];
  bool _showMap = false;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _locationController.dispose();
    _audioRecorder.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> media = await picker.pickMultiImage();
    if (media.isNotEmpty) {
      setState(() {
        _selectedMedia.addAll(media.map((m) => File(m.path)));
      });
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5), // Limit video duration to 5 minutes
    );
    if (video != null) {
      setState(() {
        _selectedMedia.add(File(video.path));
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _locationController.text = '${position.latitude}, ${position.longitude}';
        _showMap = true;
        _markers = {
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Selected Location'),
          ),
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() {
          _isRecording = true;
        });
        // Simulate waveform data
        _generateWaveformData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting recording: $e')),
      );
    }
  }

  void _generateWaveformData() {
    // Simulate real-time waveform data
    setState(() {
      _audioWaveform = List.generate(50, (index) => math.Random().nextDouble());
    });
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _voiceNote = File(path);
          _isRecording = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  void _showFullScreenMedia(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaView(
          mediaFiles: _selectedMedia,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Implement post creation
                Navigator.pop(context);
              }
            },
            child: Text(
              'Post',
              style: TextStyle(
                color: _bodyController.text.isNotEmpty ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Info with Profile Picture
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user?['name']?[0].toUpperCase() ?? '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['name'] ?? 'Unknown User',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '@${user?['username'] ?? 'username'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Post Type Selection with Modern Design
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Post Type',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPostTypeButton(
                          type: PostType.personal,
                          icon: Icons.person_outline,
                          label: 'Personal',
                          isSelected: _postType == PostType.personal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPostTypeButton(
                          type: PostType.society,
                          icon: Icons.groups_outlined,
                          label: 'Society',
                          isSelected: _postType == PostType.society,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Society Selection with Modern Design
            if (_postType == PostType.society) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Society',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSocietyId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: widget.societies.map((society) {
                        return DropdownMenuItem<String>(
                          value: society['id'] as String,
                          child: Text(society['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSocietyId = value;
                        });
                      },
                      validator: (value) {
                        if (_postType == PostType.society && value == null) {
                          return 'Please select a society';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Title Field with Modern Design
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "Enter post title",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: TextStyle(color: textColor),
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Body Field with Modern Design
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: 5,
                    style: TextStyle(color: textColor),
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter some content' : null,
                  ),
                ],
              ),
            ),

            // Media Preview
            if (_selectedMedia.isNotEmpty)
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMedia.length,
                  itemBuilder: (context, index) {
                    final isImage = _selectedMedia[index].path.toLowerCase().endsWith('.jpg') ||
                        _selectedMedia[index].path.toLowerCase().endsWith('.png') ||
                        _selectedMedia[index].path.toLowerCase().endsWith('.jpeg');
                    
                    return GestureDetector(
                      onTap: () => _showFullScreenMedia(index),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: isImage
                                  ? DecorationImage(
                                      image: FileImage(_selectedMedia[index]),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: Colors.grey[300],
                            ),
                            child: !isImage
                                ? const Center(
                                    child: Icon(Icons.video_library, size: 48),
                                  )
                                : null,
                          ),
                          Positioned(
                            top: 8,
                            right: 16,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _selectedMedia.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Voice Note Waveform
            if (_isRecording || _voiceNote != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    if (_isRecording)
                      SizedBox(
                        height: 60,
                        child: CustomPaint(
                          painter: WaveformPainter(
                            waveform: _audioWaveform,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    if (_voiceNote != null)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              // TODO: Implement audio playback
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _voiceNote = null;
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),

            // Location Section
            if (_postType == PostType.society)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map),
                          label: const Text('Show Map'),
                          onPressed: () {
                            setState(() {
                              _showMap = !_showMap;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.location_on),
                          label: const Text('Current Location'),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                    ],
                  ),
                  if (_showMap && _currentPosition != null)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            zoom: 15,
                          ),
                          markers: _markers,
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                        ),
                      ),
                    ),
                ],
              ),

            // Bottom Actions
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo_library_outlined, color: textColor),
                  onPressed: _pickMedia,
                ),
                IconButton(
                  icon: Icon(Icons.videocam_outlined, color: textColor),
                  onPressed: _pickVideo,
                ),
                IconButton(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic_none, color: textColor),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
                if (_postType == PostType.society)
                  IconButton(
                    icon: Icon(Icons.location_on_outlined, color: textColor),
                    onPressed: _getCurrentLocation,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeButton({
    required PostType type,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return InkWell(
      onTap: () {
        setState(() {
          _postType = type;
          if (type == PostType.personal) {
            _selectedSocietyId = null;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : isDark
                  ? Colors.grey[800]
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
  final int initialIndex;

  const FullScreenMediaView({
    super.key,
    required this.mediaFiles,
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

          return Center(
            child: isImage
                ? Image.file(
                    file,
                    fit: BoxFit.contain,
                  )
                : const Icon(
                    Icons.video_library,
                    size: 64,
                    color: Colors.white,
                  ),
          );
        },
      ),
    );
  }
}