import 'dart:convert';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScheduledGatherings extends StatefulWidget {
  @override
  _ScheduledGatheringsState createState() => _ScheduledGatheringsState();
}

class _ScheduledGatheringsState extends State<ScheduledGatherings> {
  List<Gathering> _gatherings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGatherings();
  }

  Future<void> _fetchGatherings() async {
    try {
      // Replace with your API call
      final String baseUrl = ApiConstants.baseUrl;
final response = await http.get(Uri.parse('$baseUrl/api/gatherings/upcoming'));
      if (response.statusCode == 200) {
        setState(() {
          _gatherings = (json.decode(response.body) as List)
              .map((g) => Gathering.fromJson(g))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load gatherings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Gatherings'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _gatherings.isEmpty
              ? Center(child: Text('No upcoming gatherings'))
              : ListView.builder(
                  itemCount: _gatherings.length,
                  itemBuilder: (context, index) {
                    final gathering = _gatherings[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(gathering.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('MMM dd, yyyy - hh:mm a').format(gathering.startTime)),
                            Text('${gathering.attendees.length} attending'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward),
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