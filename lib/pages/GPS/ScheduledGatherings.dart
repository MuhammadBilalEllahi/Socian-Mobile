import 'dart:convert';
import 'dart:io' as IO;
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';

class ScheduledGatherings extends ConsumerStatefulWidget {
  const ScheduledGatherings({super.key});

  @override
  ConsumerState<ScheduledGatherings> createState() => _ScheduledGatheringsState();
}

class _ScheduledGatheringsState extends ConsumerState<ScheduledGatherings> {
  final String baseUrl = ApiConstants.baseUrl;
  List<dynamic> _gatherings = [];
  String? errorMessage;
  bool _isLoading = true;
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _fetchGatherings();
    _initSocket();
  }

  void _initSocket() {
    try {
      _socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket?.connect();

      _socket?.on('connect', (_) {
        print('Connected to Socket.IO server');
      });

      _socket?.on('gatheringUpdate', (data) {
        _fetchGatherings();
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
      final auth = ref.read(authProvider);
        final url = '$baseUrl/api/gatherings/upcoming';
  print('Attempting to fetch from: $url'); // Add this line

      final response = await http.get(
        Uri.parse('$baseUrl/api/gatherings/upcoming'),
        headers: {
          'Authorization': 'Bearer ${auth.token}',
        },
      );
    print('Response status: ${response.statusCode}'); // Add this line

      if (response.statusCode == 200) {
        setState(() {
          _gatherings = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load gatherings: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border =
        isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent =
        isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Scheduled Gatherings',
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
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
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
                          backgroundColor: muted,
                          foregroundColor: foreground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
              : _gatherings.isEmpty
                  ? Center(
                      child: Text(
                        'No upcoming gatherings',
                        style: TextStyle(
                          color: mutedForeground,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _gatherings.length,
                      itemBuilder: (context, index) {
                        final gathering = _gatherings[index];
                        final startTime = DateTime.parse(gathering['startTime']);
                        final endTime = DateTime.parse(gathering['endTime']);
                        final now = DateTime.now();
                        final isActive = now.isAfter(startTime) && now.isBefore(endTime);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              gathering['title'],
                              style: TextStyle(
                                color: foreground,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  gathering['description'] ?? '',
                                  style: TextStyle(
                                    color: mutedForeground,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: mutedForeground,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(startTime),
                                      style: TextStyle(
                                        color: mutedForeground,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: mutedForeground,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${DateFormat('hh:mm a').format(startTime)} - ${DateFormat('hh:mm a').format(endTime)}',
                                      style: TextStyle(
                                        color: mutedForeground,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    isActive ? 'Active Now' : 'Upcoming',
                                    style: TextStyle(
                                      color: isActive ? Colors.green : Colors.blue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GatheringDetailScreen(gathering: gathering),
                            ),
                          );
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}

class GatheringDetailScreen extends StatefulWidget {
  final Gathering gathering;

  GatheringDetailScreen({required this.gathering});

  @override
  _GatheringDetailScreenState createState() => _GatheringDetailScreenState();
}

class _GatheringDetailScreenState extends State<GatheringDetailScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  bool _isWithinRadius = false;
  bool _isGatheringActive = false;
  bool _hasMarkedAttendance = false;

  @override
  void initState() {
    super.initState();
    _checkGatheringStatus();
    _getUserLocation();
  }

  void _checkGatheringStatus() {
    final now = DateTime.now();
    setState(() {
      _isGatheringActive = now.isAfter(widget.gathering.startTime) &&
          now.isBefore(widget.gathering.endTime);
    });
  }

  Future<void> _getUserLocation() async {
    // Implement location fetching logic
    // Then check if within radius
    _checkIfWithinRadius();
  }

  void _checkIfWithinRadius() {
    if (_userLocation == null) return;
    
    final distance = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      widget.gathering.location.latitude,
      widget.gathering.location.longitude,
    );

    setState(() {
      _isWithinRadius = distance <= widget.gathering.radius;
    });
  }

  Future<void> _markAttendance() async {
          final String baseUrl = ApiConstants.baseUrl;

    try {
      // Replace with your API call
      final response = await http.post(Uri.parse
        ('$baseUrl/api/gatherings/${widget.gathering.id}/attend'),
        body: json.encode({
          'latitude': _userLocation!.latitude,
          'longitude': _userLocation!.longitude,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() => _hasMarkedAttendance = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark attendance')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gatheringLocation = LatLng(
      widget.gathering.location.latitude,
      widget.gathering.location.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gathering.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: gatheringLocation,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(gatheringLocation),
                );
              },
              markers: {
                Marker(
                  markerId: MarkerId('gathering_location'),
                  position: gatheringLocation,
                  infoWindow: InfoWindow(title: widget.gathering.title),
                ),
                if (_userLocation != null)
                  Marker(
                    markerId: MarkerId('user_location'),
                    position: _userLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  ),
                ...widget.gathering.attendees.map((attendee) => Marker(
                  markerId: MarkerId(attendee.userId),
                  position: LatLng(attendee.location.latitude, attendee.location.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                )),
              },
              circles: {
                Circle(
                  circleId: CircleId('radius'),
                  center: gatheringLocation,
                  radius: widget.gathering.radius.toDouble(),
                  fillColor: Colors.blue.withOpacity(0.2),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.gathering.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(widget.gathering.description ?? ''),
                SizedBox(height: 8),
                Text('Starts: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.gathering.startTime)}'),
                Text('Ends: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.gathering.endTime)}'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isGatheringActive && _isWithinRadius && !_hasMarkedAttendance
                      ? _markAttendance
                      : null,
                  child: Text('I\'m Here'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Gathering {
  final String id;
  final String title;
  final String? description;
  final Location location;
  final int radius;
  final DateTime startTime;
  final DateTime endTime;
  final List<Attendee> attendees;

  Gathering({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.radius,
    required this.startTime,
    required this.endTime,
    required this.attendees,
  });

  factory Gathering.fromJson(Map<String, dynamic> json) {
    return Gathering(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      location: Location.fromJson(json['location']),
      radius: json['radius'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      attendees: (json['attendees'] as List).map((a) => Attendee.fromJson(a)).toList(),
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class Attendee {
  final String userId;
  final Location location;
  final DateTime timestamp;

  Attendee({
    required this.userId,
    required this.location,
    required this.timestamp,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      userId: json['userId'],
      location: Location.fromJson(json['location']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}