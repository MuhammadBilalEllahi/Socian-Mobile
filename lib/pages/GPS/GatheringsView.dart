import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';

class GatheringsView extends ConsumerStatefulWidget {
  const GatheringsView({super.key});

  @override
  ConsumerState<GatheringsView> createState() => _GatheringsViewState();
}

class _GatheringsViewState extends ConsumerState<GatheringsView> {
  final String baseUrl = ApiConstants.baseUrl;
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _currentGatherings = [];
  String? errorMessage;
  bool _isLoading = true;
  IO.Socket? _socket;
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  Map<String, BitmapDescriptor> _gatheringIcons = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchGatherings();
    _initSocket();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting user location: $e');
      // Fallback to a default location (e.g., city center)
      setState(() {
        _userLocation = const LatLng(0.0, 0.0); // Replace with your default coordinates
      });
    }
    if (_mapController != null && _userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 12),
      );
    }
  }

  void _initSocket() {
    try {
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });

      _socket?.connect();

      _socket?.on('connect', (_) {
        print('Connected to Socket.IO server');
      });

      _socket?.on('reconnect', (_) {
        print('Reconnected to Socket.IO server');
      });

      _socket?.on('gatheringUpdate', (data) {
        print('Gathering update received: $data');
        _fetchGatherings();
      });

      _socket?.on('attendanceUpdate', (data) {
        print('Attendance update received: $data');
        final gatheringId = data['gatheringId']?.toString();
        final attendees = data['attendees'] as List<dynamic>?;

        if (gatheringId == null || attendees == null) return;

        setState(() {
          final index = _currentGatherings.indexWhere((g) => g['_id']?.toString() == gatheringId);
          if (index != -1) {
            _currentGatherings[index]['attendees'] = attendees;
            _updateMapElements();
          }
        });
      });

      _socket?.on('error', (error) => print('Socket error: $error'));
      _socket?.on('disconnect', (_) => print('Disconnected from Socket.IO server'));
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  Future<void> _fetchGatherings() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiClient.getList('/api/gatherings/all');
      final now = DateTime.now();

      setState(() {
        _currentGatherings.clear();
        final gatherings = (response as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

        for (var gathering in gatherings) {
          final startTime = DateTime.tryParse(gathering['startTime']?.toString() ?? '')?.toLocal();
          final endTime = DateTime.tryParse(gathering['endTime']?.toString() ?? '')?.toLocal();

          if (startTime == null || endTime == null) continue;

          if (startTime.isBefore(now) && endTime.isAfter(now)) {
            _currentGatherings.add(gathering);
          }
        }

        _isLoading = false;
      });

      await _updateMapElements();
      print('Current gatherings: ${_currentGatherings.map((g) => g['title']).toList()}');
    } catch (e) {
      print('Error fetching gatherings: $e');
      setState(() {
        errorMessage = e is ApiException ? e.message : 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMapElements() async {
    final newMarkers = <Marker>{};
    final newCircles = <Circle>{};

    for (var gathering in _currentGatherings) {
      final gatheringId = gathering['_id']?.toString() ?? '';
      final location = LatLng(
        double.tryParse(gathering['location']?['latitude']?.toString() ?? '') ?? 0.0,
        double.tryParse(gathering['location']?['longitude']?.toString() ?? '') ?? 0.0,
      );
      final radius = int.tryParse(gathering['radius']?.toString() ?? '') ?? 100;
      final attendeesCount = (gathering['attendees'] as List<dynamic>?)?.length ?? 0;

      // Generate or retrieve icon
      if (!_gatheringIcons.containsKey(gatheringId)) {
        _gatheringIcons[gatheringId] = await _createGatheringIcon(gatheringId, attendeesCount);
      }

      // Generate deterministic color based on gathering ID
      final color = _generateColor(gatheringId);

      // Add circle
      newCircles.add(
        Circle(
          circleId: CircleId(gatheringId),
          center: location,
          radius: radius.toDouble(),
          fillColor: color.withOpacity(0.3),
          strokeColor: color,
          strokeWidth: 2,
        ),
      );

      // Add marker
      newMarkers.add(
        Marker(
          markerId: MarkerId(gatheringId),
          position: location,
          icon: _gatheringIcons[gatheringId] ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: gathering['title']?.toString() ?? 'Untitled',
            snippet: '$attendeesCount attending',
            onTap: () {
              // Optionally navigate to GatheringDetailScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GatheringDetailScreen(
                    gathering: Gathering.fromJson(gathering),
                    socket: _socket,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
      _circles = newCircles;
    });
  }

  Color _generateColor(String gatheringId) {
    final random = Random(gatheringId.hashCode);
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  Future<BitmapDescriptor> _createGatheringIcon(String gatheringId, int attendeesCount) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = _generateColor(gatheringId);
    const size = 48.0;

    // Draw circle
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    // Draw attendee count
    final textPainter = TextPainter(
      text: TextSpan(
        text: attendeesCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final primaryColor = isDarkMode ? const Color(0xFF6366F1) : const Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Current Gatherings',
          style: TextStyle(
            color: foreground,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: foreground),
            onPressed: _fetchGatherings,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading gatherings...',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _fetchGatherings,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _currentGatherings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: mutedForeground,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No gatherings happening now',
                            style: TextStyle(
                              color: mutedForeground,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _userLocation ?? const LatLng(0.0, 0.0),
                        zoom: 12,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (_userLocation != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(_userLocation!, 12),
                          );
                        }
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _markers,
                      circles: _circles,
                    ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

// Reusing models from scheduled_gatherings.dart
class Gathering {
  final String id;
  final String title;
  final String? description;
  final Location location;
  final int radius;
  final DateTime startTime;
  final DateTime endTime;
  final List<Attendee> attendees;
  final String creatorId;
  final String creatorName;

  Gathering({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.radius,
    required this.startTime,
    required this.endTime,
    required this.attendees,
    required this.creatorId,
    required this.creatorName,
  });

  factory Gathering.fromJson(Map<String, dynamic> json) {
    return Gathering(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      radius: int.tryParse(json['radius']?.toString() ?? '') ?? 100,
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      attendees: (json['attendees'] as List<dynamic>?)?.map((a) => Attendee.fromJson(a as Map<String, dynamic>)).toList() ?? [],
      creatorId: (json['creatorId'] is Map
          ? json['creatorId']['_id']?.toString()
          : (json['creatorId'] is List && json['creatorId'].isNotEmpty
              ? json['creatorId'][0]['_id']?.toString()
              : json['creatorId']?.toString())) ?? '',
      creatorName: (json['creatorId'] is Map
          ? json['creatorId']['name']?.toString()
          : (json['creatorId'] is List && json['creatorId'].isNotEmpty
              ? json['creatorId'][0]['name']?.toString()
              : json['creatorId']?.toString())) ?? 'Unknown',
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
    );
  }
}

class Attendee {
  final String userId;
  final String name;
  final Location location;
  final DateTime timestamp;

  Attendee({
    required this.userId,
    required this.name,
    required this.location,
    required this.timestamp,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    print('Attendee JSON: $json');
    return Attendee(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      location: Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}

// Assuming GatheringDetailScreen is defined in scheduled_gatherings.dart
class GatheringDetailScreen extends StatefulWidget {
  final Gathering gathering;
  final IO.Socket? socket;

  const GatheringDetailScreen({super.key, required this.gathering, this.socket});

  @override
  State<GatheringDetailScreen> createState() => _GatheringDetailScreenState();
}

class _GatheringDetailScreenState extends State<GatheringDetailScreen> {
  // Placeholder: Implement as per scheduled_gatherings.dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.gathering.title)),
      body: const Center(child: Text('Gathering Detail Screen')),
    );
  }
}