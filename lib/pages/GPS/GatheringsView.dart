import 'dart:async';
import 'dart:math';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  Set<Circle> _circles = {};
  Map<String, Color> _gatheringColors = {};
  bool _isDropdownOpen = false;
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchGatherings();
    _initSocket();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        setState(() {
          _userLocation = _defaultLocation;
        });
        _updateMapCamera();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          setState(() {
            _userLocation = _defaultLocation;
          });
          _updateMapCamera();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
        setState(() {
          _userLocation = _defaultLocation;
        });
        _updateMapCamera();
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _updateMapCamera();
    } catch (e) {
      print('Error getting user location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
      setState(() {
        _userLocation = _defaultLocation;
      });
      _updateMapCamera();
    }
  }

  void _updateMapCamera() {
    if (_mapController != null && _userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 14),
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
      print('Current gatherings: ${_currentGatherings.map((g) => {'title': g['title'], 'attendees': (g['attendees'] as List<dynamic>?)?.length ?? 0}).toList()}');
    } catch (e) {
      print('Error fetching gatherings: $e');
      setState(() {
        errorMessage = e is ApiException ? e.message : 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMapElements() async {
    final newCircles = <Circle>{};
    final newColors = <String, Color>{};

    for (var gathering in _currentGatherings) {
      final gatheringId = gathering['_id']?.toString() ?? '';
      final location = LatLng(
        double.tryParse(gathering['location']?['latitude']?.toString() ?? '') ?? 0.0,
        double.tryParse(gathering['location']?['longitude']?.toString() ?? '') ?? 0.0,
      );
      final radius = int.tryParse(gathering['radius']?.toString() ?? '') ?? 100;

      // Generate deterministic color based on gathering ID
      final color = _generateColor(gatheringId);

      // Store color for menu
      newColors[gatheringId] = color;

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
    }

    setState(() {
      _circles = newCircles;
      _gatheringColors = newColors;
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
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _userLocation ?? _defaultLocation,
                            zoom: 14,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                            _updateMapCamera();
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: {}, // No markers
                          circles: _circles,
                        ),
                         Positioned(
                          left: 10,
                          top: kToolbarHeight + MediaQuery.of(context).padding.top + 10, // Below AppBar
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: MediaQuery.of(context).size.width * 0.5, // 50% of screen width
                            height: _isDropdownOpen
                                ? MediaQuery.of(context).size.height * 0.6 // Max 60% height when open
                                : 50.0, // Fixed height when closed
                            decoration: BoxDecoration(
                              color: background.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isDropdownOpen = !_isDropdownOpen;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Details',
                                          style: TextStyle(
                                            color: foreground,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
                                          color: foreground,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_isDropdownOpen)
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: _currentGatherings.length,
                                      itemBuilder: (context, index) {
                                        final gathering = _currentGatherings[index];
                                        final gatheringId = gathering['_id']?.toString() ?? '';
                                        final title = gathering['title']?.toString() ?? 'Untitled';
                                        final attendeesCount = (gathering['attendees'] as List<dynamic>?)?.length ?? 0;
                                        final color = _gatheringColors[gatheringId] ?? Colors.grey;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                attendeesCount == 1 ? '1 joinee' : '$attendeesCount joinees',
                                                style: TextStyle(
                                                  color: mutedForeground,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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

  @override
  void dispose() {
    _mapController?.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

class Gathering {
  final String id;
  final String title;
  final Location location;
  final int radius;
  final DateTime startTime;
  final DateTime endTime;
  final List<dynamic> attendees;

  Gathering({
    required this.id,
    required this.title,
    required this.location,
    required this.radius,
    required this.startTime,
    required this.endTime,
    required this.attendees,
  });

  factory Gathering.fromJson(Map<String, dynamic> json) {
    return Gathering(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      location: Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      radius: int.tryParse(json['radius']?.toString() ?? '') ?? 100,
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      attendees: (json['attendees'] as List<dynamic>?) ?? [],
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