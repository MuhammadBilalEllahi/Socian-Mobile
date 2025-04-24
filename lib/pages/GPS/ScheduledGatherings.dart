// import 'dart:convert';
// import 'package:beyondtheclass/core/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:intl/intl.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ScheduledGatherings extends ConsumerStatefulWidget {
//   const ScheduledGatherings({super.key});

//   @override
//   ConsumerState<ScheduledGatherings> createState() => _ScheduledGatheringsState();
// }

// class _ScheduledGatheringsState extends ConsumerState<ScheduledGatherings> {
//   final String baseUrl = ApiConstants.baseUrl;
//   final ApiClient _apiClient = ApiClient();
//   List<dynamic> _gatherings = [];
//   String? errorMessage;
//   bool _isLoading = true;
//   IO.Socket? _socket;

//   @override
//   void initState() {
//     super.initState();
//     _fetchGatherings();
//     _initSocket();
//   }

//   void _initSocket() {
//     try {
//       _socket = IO.io(baseUrl, <String, dynamic>{
//         'transports': ['websocket'],
//         'autoConnect': false,
//       });

//       _socket?.connect();

//       _socket?.on('connect', (_) {
//         print('Connected to Socket.IO server');
//       });

//       _socket?.on('gatheringUpdate', (data) {
//         print('Gathering update received: $data');
//         _fetchGatherings();
//       });

//       _socket?.on('error', (error) => print('Socket error: $error'));
//       _socket?.on('disconnect', (_) => print('Disconnected from Socket.IO server'));
//     } catch (e) {
//       print('Socket initialization error: $e');
//     }
//   }

//   Future<void> _fetchGatherings() async {
//     setState(() {
//       _isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       print('Attempting to fetch from: $baseUrl/api/gatherings/upcoming');
//       final response = await _apiClient.getList('/api/gatherings/upcoming');
//       print('Response data: $response');

//       setState(() {
//         _gatherings = response;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching gatherings: $e');
//       setState(() {
//         errorMessage = e is ApiException ? e.message : 'Error: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
//     final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: background,
//         elevation: 0,
//         title: Text(
//           'Scheduled Gatherings',
//           style: TextStyle(
//             color: foreground,
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: foreground),
//             onPressed: _fetchGatherings,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(foreground),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Loading gatherings...',
//                     style: TextStyle(
//                       color: foreground,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         color: Colors.red[400],
//                         size: 48,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         errorMessage!,
//                         style: TextStyle(
//                           color: foreground,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 24),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: muted,
//                           foregroundColor: foreground,
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: _fetchGatherings,
//                         child: const Text('Try Again'),
//                       ),
//                     ],
//                   ),
//                 )
//               : _gatherings.isEmpty
//                   ? Center(
//                       child: Text(
//                         'No upcoming gatherings',
//                         style: TextStyle(
//                           color: mutedForeground,
//                           fontSize: 16,
//                         ),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: _gatherings.length,
//                       itemBuilder: (context, index) {
//                         final gathering = _gatherings[index];
//                         final startTime = DateTime.parse(gathering['startTime']);
//                         final endTime = DateTime.parse(gathering['endTime']);
//                         final now = DateTime.now();
//                         final isActive = now.isAfter(startTime) && now.isBefore(endTime);

//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 16),
//                           decoration: BoxDecoration(
//                             color: accent,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: border),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: ListTile(
//                             contentPadding: const EdgeInsets.all(16),
//                             title: Text(
//                               gathering['title'],
//                               style: TextStyle(
//                                 color: foreground,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   gathering['description'] ?? '',
//                                   style: TextStyle(
//                                     color: mutedForeground,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.calendar_today,
//                                       size: 16,
//                                       color: mutedForeground,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       DateFormat('MMM dd, yyyy').format(startTime),
//                                       style: TextStyle(
//                                         color: mutedForeground,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.access_time,
//                                       size: 16,
//                                       color: mutedForeground,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       '${DateFormat('hh:mm a').format(startTime)} - ${DateFormat('hh:mm a').format(endTime)}',
//                                       style: TextStyle(
//                                         color: mutedForeground,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: isActive ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   child: Text(
//                                     isActive ? 'Active Now' : 'Upcoming',
//                                     style: TextStyle(
//                                       color: isActive ? Colors.green : Colors.blue,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => GatheringDetailScreen(
//                                     gathering: Gathering.fromJson(gathering),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }

//   @override
//   void dispose() {
//     _socket?.disconnect();
//     _socket?.dispose();
//     super.dispose();
//   }
// }

// class GatheringDetailScreen extends StatefulWidget {
//   final Gathering gathering;

//   const GatheringDetailScreen({super.key, required this.gathering});

//   @override
//   _GatheringDetailScreenState createState() => _GatheringDetailScreenState();
// }

// class _GatheringDetailScreenState extends State<GatheringDetailScreen> {
//   final ApiClient _apiClient = ApiClient();
//   GoogleMapController? _mapController;
//   LatLng? _userLocation;
//   bool _isWithinRadius = false;
//   bool _isGatheringActive = false;
//   bool _hasMarkedAttendance = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkGatheringStatus();
//     _getUserLocation();
//   }

//   void _checkGatheringStatus() {
//     final now = DateTime.now();
//     setState(() {
//       _isGatheringActive = now.isAfter(widget.gathering.startTime) && now.isBefore(widget.gathering.endTime);
//     });
//   }

//   Future<void> _getUserLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _userLocation = LatLng(position.latitude, position.longitude);
//       });
//       _checkIfWithinRadius();
//     } catch (e) {
//       print('Error getting user location: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to get location: $e')),
//       );
//     }
//   }

//   void _checkIfWithinRadius() {
//     if (_userLocation == null) return;

//     final distance = Geolocator.distanceBetween(
//       _userLocation!.latitude,
//       _userLocation!.longitude,
//       widget.gathering.location.latitude,
//       widget.gathering.location.longitude,
//     );

//     setState(() {
//       _isWithinRadius = distance <= widget.gathering.radius;
//     });
//   }

//   Future<void> _markAttendance() async {
//     try {
//       final data = {
//         'latitude': _userLocation!.latitude,
//         'longitude': _userLocation!.longitude,
//       };

//       print('Marking attendance with data: $data');
//       final response = await _apiClient.post(
//         '/api/gatherings/${widget.gathering.id}/attend',
//         data,
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('Attendance response: $response');
//       setState(() {
//         _hasMarkedAttendance = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Attendance marked successfully')),
//       );
//     } catch (e) {
//       print('Error marking attendance: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to mark attendance: ${e is ApiException ? e.message : e.toString()}')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final gatheringLocation = LatLng(
//       widget.gathering.location.latitude,
//       widget.gathering.location.longitude,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.gathering.title),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: GoogleMap(
//               initialCameraPosition: CameraPosition(
//                 target: gatheringLocation,
//                 zoom: 15,
//               ),
//               onMapCreated: (controller) {
//                 _mapController = controller;
//                 _mapController?.animateCamera(
//                   CameraUpdate.newLatLng(gatheringLocation),
//                 );
//               },
//               markers: {
//                 Marker(
//                   markerId: const MarkerId('gathering_location'),
//                   position: gatheringLocation,
//                   infoWindow: InfoWindow(title: widget.gathering.title),
//                 ),
//                 if (_userLocation != null)
//                   Marker(
//                     markerId: const MarkerId('user_location'),
//                     position: _userLocation!,
//                     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//                   ),
//                 ...widget.gathering.attendees.map(
//                   (attendee) => Marker(
//                     markerId: MarkerId(attendee.userId),
//                     position: LatLng(attendee.location.latitude, attendee.location.longitude),
//                     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//                   ),
//                 ),
//               },
//               circles: {
//                 Circle(
//                   circleId: const CircleId('radius'),
//                   center: gatheringLocation,
//                   radius: widget.gathering.radius.toDouble(),
//                   fillColor: Colors.blue.withOpacity(0.2),
//                   strokeColor: Colors.blue,
//                   strokeWidth: 2,
//                 ),
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.gathering.title,
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(widget.gathering.description ?? ''),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Starts: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.gathering.startTime)}',
//                 ),
//                 Text(
//                   'Ends: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.gathering.endTime)}',
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _isGatheringActive && _isWithinRadius && !_hasMarkedAttendance ? _markAttendance : null,
//                   child: const Text("I'm Here"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
// }

// class Gathering {
//   final String id;
//   final String title;
//   final String? description;
//   final Location location;
//   final int radius;
//   final DateTime startTime;
//   final DateTime endTime;
//   final List<Attendee> attendees;

//   Gathering({
//     required this.id,
//     required this.title,
//     this.description,
//     required this.location,
//     required this.radius,
//     required this.startTime,
//     required this.endTime,
//     required this.attendees,
//   });

//   factory Gathering.fromJson(Map<String, dynamic> json) {
//     return Gathering(
//       id: json['_id'],
//       title: json['title'],
//       description: json['description'],
//       location: Location.fromJson(json['location']),
//       radius: json['radius'],
//       startTime: DateTime.parse(json['startTime']),
//       endTime: DateTime.parse(json['endTime']),
//       attendees: (json['attendees'] as List).map((a) => Attendee.fromJson(a)).toList(),
//     );
//   }
// }

// class Location {
//   final double latitude;
//   final double longitude;

//   Location({required this.latitude, required this.longitude});

//   factory Location.fromJson(Map<String, dynamic> json) {
//     return Location(
//       latitude: json['latitude'].toDouble(),
//       longitude: json['longitude'].toDouble(),
//     );
//   }
// }

// class Attendee {
//   final String userId;
//   final Location location;
//   final DateTime timestamp;

//   Attendee({
//     required this.userId,
//     required this.location,
//     required this.timestamp,
//   });

//   factory Attendee.fromJson(Map<String, dynamic> json) {
//     return Attendee(
//       userId: json['userId'],
//       location: Location.fromJson(json['location']),
//       timestamp: DateTime.parse(json['timestamp']),
//     );
//   }
// }
















//////////////////////////////////////////////////////////////////////////////////
///
///
///
///
import 'dart:convert';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';

class ScheduledGatherings extends ConsumerStatefulWidget {
  const ScheduledGatherings({super.key});

  @override
  ConsumerState<ScheduledGatherings> createState() => _ScheduledGatheringsState();
}

class _ScheduledGatheringsState extends ConsumerState<ScheduledGatherings> {
  final String baseUrl = ApiConstants.baseUrl;
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _gatherings = [];
  String? errorMessage;
  bool _isLoading = true;
  IO.Socket? _socket;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchGatherings();
    _initSocket();
  }

  Future<void> _loadUserId() async {
    try {
      final token = await SecureStorageService.instance.getToken();
      if (token != null) {
        final decoded = JwtDecoder.decode(token);
        setState(() {
          _userId = decoded['_id']?.toString();
        });
        print('User ID loaded: $_userId');
      } else {
        print('No token found');
      }
    } catch (e) {
      print('Error decoding token: $e');
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
      print('Attempting to fetch from: $baseUrl/api/gatherings/upcoming');
      final response = await _apiClient.getList('/api/gatherings/upcoming');
      print('Response data: $response');
      print('Response length: ${(response as List<dynamic>?)?.length ?? 0}');

      setState(() {
        _gatherings.clear();
        _gatherings = (response as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        _isLoading = false;
      });
      print('Updated gatherings: ${_gatherings.map((g) => g['title']).toList()}');
    } catch (e) {
      print('Error fetching gatherings: $e');
      setState(() {
        errorMessage = e is ApiException ? e.message : 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGathering(String gatheringId) async {
    try {
      print('Deleting gathering: $gatheringId');
      final response = await _apiClient.delete('/api/gatherings/$gatheringId');
      print('Delete response: $response');

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gathering deleted successfully')),
        );
        await _fetchGatherings();
      }
    } catch (e) {
      print('Error deleting gathering: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete gathering: ${e is ApiException ? e.message : e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);

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
                        print('Gathering $index: ID: ${gathering['_id']}, Title: ${gathering['title']}, StartTime: ${gathering['startTime']}');
                        print('Gathering $index: creatorId: ${gathering['creatorId']}, Type: ${gathering['creatorId'].runtimeType}');
                        print('Gathering $index: assigned creatorName: ${(gathering['creatorId'] is Map ? gathering['creatorId']['name'] : (gathering['creatorId'] is List ? gathering['creatorId'][0]['name'] : gathering['creatorId']))}');
                        final startTime = DateTime.tryParse(gathering['startTime']?.toString() ?? '')?.toLocal() ?? DateTime.now();
                        final endTime = DateTime.tryParse(gathering['endTime']?.toString() ?? '')?.toLocal() ?? DateTime.now();
                        final now = DateTime.now();
                        final isActive = now.isAfter(startTime) && now.isBefore(endTime);
                        final isCreator = _userId != null && _userId == (gathering['creatorId'] is Map ? gathering['creatorId']['_id']?.toString() : gathering['creatorId']?.toString());

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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              gathering['title']?.toString() ?? 'Untitled',
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
                                  gathering['description']?.toString() ?? '',
                                  style: TextStyle(
                                    color: mutedForeground,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scheduled by: ${(gathering['creatorId'] is Map ? gathering['creatorId']['name']?.toString() : (gathering['creatorId'] is List && gathering['creatorId'].isNotEmpty ? gathering['creatorId'][0]['name']?.toString() : gathering['creatorId']?.toString())) ?? 'Unknown'}',
                                  style: TextStyle(
                                    color: mutedForeground,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
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
                            trailing: isCreator
                                ? PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: foreground),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Gathering'),
                                            content: const Text('Are you sure you want to delete this gathering?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _deleteGathering(gathering['_id']?.toString() ?? '');
                                                },
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GatheringDetailScreen(
                                    gathering: Gathering.fromJson(gathering),
                                  ),
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

  const GatheringDetailScreen({super.key, required this.gathering});

  @override
  State<GatheringDetailScreen> createState() => _GatheringDetailScreenState();
}

class _GatheringDetailScreenState extends State<GatheringDetailScreen> {
  final ApiClient _apiClient = ApiClient();
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
      _isGatheringActive = now.isAfter(widget.gathering.startTime) && now.isBefore(widget.gathering.endTime);
    });
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _checkIfWithinRadius();
    } catch (e) {
      print('Error getting user location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
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
    if (_userLocation == null) return;

    try {
      final data = {
        'latitude': _userLocation!.latitude,
        'longitude': _userLocation!.longitude,
      };

      print('Marking attendance with data: $data');
      final response = await _apiClient.post(
        '/api/gatherings/${widget.gathering.id}/attend',
        data,
        headers: {'Content-Type': 'application/json'},
      );

      print('Attendance response: $response');
      setState(() {
        _hasMarkedAttendance = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully')),
      );
    } catch (e) {
      print('Error marking attendance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark attendance: ${e is ApiException ? e.message : e.toString()}')),
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
                  markerId: const MarkerId('gathering_location'),
                  position: gatheringLocation,
                  infoWindow: InfoWindow(title: widget.gathering.title),
                ),
                if (_userLocation != null)
                  Marker(
                    markerId: const MarkerId('user_location'),
                    position: _userLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  ),
                ...widget.gathering.attendees.map(
                  (attendee) => Marker(
                    markerId: MarkerId(attendee.userId),
                    position: LatLng(attendee.location.latitude, attendee.location.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  ),
                ),
              },
              circles: {
                Circle(
                  circleId: const CircleId('radius'),
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
                Text(
                  widget.gathering.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.gathering.description ?? ''),
                const SizedBox(height: 8),
                Text(
                  'Starts: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.gathering.startTime)}',
                ),
                Text(
                  'Ends: ${DateFormat('MMM dd, yyyy - hh:mm a').format(widget.gathering.endTime)}',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isGatheringActive && _isWithinRadius && !_hasMarkedAttendance ? _markAttendance : null,
                  child: const Text("I'm Here"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
  final Location location;
  final DateTime timestamp;

  Attendee({
    required this.userId,
    required this.location,
    required this.timestamp,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      userId: json['userId']?.toString() ?? '',
      location: Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}