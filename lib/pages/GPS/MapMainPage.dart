import 'dart:convert';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';

class MapMainPage extends ConsumerStatefulWidget {
  const MapMainPage({super.key});

  @override
  ConsumerState<MapMainPage> createState() => _MapMainPageState();
}

class _MapMainPageState extends ConsumerState<MapMainPage> {
  final String apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
  final String baseUrl = ApiConstants.baseUrl;
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  String? errorMessage;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  IO.Socket? _socket;
  double _radius = 500.0;
  int _userCountInRadius = 0;
  bool _isLoading = true;

  BitmapDescriptor? _userMarkerIcon;
  BitmapDescriptor? _otherMarkerIcon;

  @override
  void initState() {
    super.initState();
    _setMarkerIcons();
    _fetchLocationWithTimeout();
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

      _socket?.on('attendeeLocationUpdate', (data) {
        if (data != null) {
          final userId = data['userId']?.toString() ?? data['id']?.toString() ?? 'unknown';
          final isWithinRadius = _isWithinRadius(data['latitude'], data['longitude']);
          
          setState(() {
            // Remove existing marker if it exists
            _markers.removeWhere((m) => m.markerId.value == userId);
            
            if (isWithinRadius && userId != ref.read(authProvider).user?['id']?.toString()) {
              _markers.add(
                Marker(
                  markerId: MarkerId(userId),
                  position: LatLng(data['latitude'], data['longitude']),
                  icon: _otherMarkerIcon ?? BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(title: data['name'] ?? "Unknown"),
                ),
              );
            }
            _updateUserCount();
          });
        }
      });

      _socket?.on('attendeesList', (data) {
        if (data is List) {
          setState(() {
            // Clear all markers except the user's own marker
            _markers.removeWhere((m) => m.markerId.value != "user_location");
            
            for (var user in data) {
              final userId = user['userId']?.toString() ?? user['id']?.toString() ?? 'unknown';
              if (_isWithinRadius(user['latitude'], user['longitude']) &&
                  userId != ref.read(authProvider).user?['id']?.toString()) {
                _markers.add(
                  Marker(
                    markerId: MarkerId(userId),
                    position: LatLng(user['latitude'], user['longitude']),
                    icon: _otherMarkerIcon ?? BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(title: user['name'] ?? "Unknown"),
                  ),
                );
              }
            }
            _updateUserCount();
          });
        }
      });

      _socket?.on('error', (error) => print('Socket error: $error'));
      _socket?.on('disconnect', (_) => print('Disconnected from Socket.IO server'));
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  void _updateUserCount() {
    // Count all markers except the user's own marker
    _userCountInRadius = _markers.where((m) => m.markerId.value != "user_location").length;
  }

  Future<void> _setMarkerIcons() async {
    _userMarkerIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    _otherMarkerIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  Future<void> _fetchLocationWithTimeout() async {
    setState(() => _isLoading = true);
    try {
      // Clear existing markers except user's marker
      setState(() {
        _markers.removeWhere((m) => m.markerId.value != "user_location");
        _updateUserCount();
      });
      
      await _checkPermissionsAndFetchLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception("Location fetch timed out");
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermissionsAndFetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage = "Location service is disabled";
        _isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage = "Location permission denied";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage = "Location permissions permanently denied";
        _isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      // Remove existing user marker if it exists
      _markers.removeWhere((m) => m.markerId.value == "user_location");
      
      final auth = ref.read(authProvider);
      _markers.add(Marker(
        markerId: const MarkerId("user_location"),
        position: _userLocation!,
        icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: auth.user?['name'] ?? "Your Location"),
      ));
      _updateCircle();
      _isLoading = false;
      _updateUserCount();
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 15));
    _sendLocationUpdate();
    _requestNearbyAttendees();
  }

  void _sendLocationUpdate() {
    if (_userLocation == null || _socket == null || !_socket!.connected) return;

    final auth = ref.read(authProvider);
    final userData = {
      'userId': auth.user?['id']?.toString() ?? 'default_user_id',
      'name': auth.user?['name'] ?? 'Unknown',
      'latitude': _userLocation!.latitude,
      'longitude': _userLocation!.longitude,
      'radius': _radius,
    };

    _socket?.emit('updateLocation', userData);
  }

  void _requestNearbyAttendees() {
    if (_socket == null || !_socket!.connected) return;
    _socket?.emit('requestAttendees');
  }

  void _updateCircle() {
    setState(() {
      _circles.clear();
      if (_userLocation != null) {
        _circles.add(
          Circle(
            circleId: const CircleId("radius"),
            center: _userLocation!,
            radius: _radius,
            fillColor: Colors.blue.withOpacity(0.2),
            strokeColor: Colors.blue,
            strokeWidth: 2,
          ),
        );
      }
    });
  }

  bool _isWithinRadius(double lat, double lng) {
    if (_userLocation == null) return false;
    double distance = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      lat,
      lng,
    );
    return distance <= _radius;
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
          'Meeting Point',
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
            onPressed: _fetchLocationWithTimeout,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_userLocation != null)
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _userLocation!,
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _markers,
              circles: _circles,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            )
          else if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Setting up meeting point...',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else if (errorMessage != null)
            Center(
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
                    onPressed: _fetchLocationWithTimeout,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '$_userCountInRadius users in radius',
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: background,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Meeting Radius: ${_radius.round()}m',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _radius,
                    min: 10,
                    max: 500,
                    divisions: 20,
                    label: "${_radius.round()}m",
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                        _updateCircle();
                        _sendLocationUpdate();
                        _requestNearbyAttendees();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_markers.length > 1)
            Positioned(
              top: 80,
              left: 16,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: background,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Nearby Users',
                        style: TextStyle(
                          color: foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ..._markers
                        .where((marker) =>
                            marker.markerId.value != "user_location")
                        .map((marker) => ListTile(
                              title: Text(
                                marker.infoWindow.title ?? "Unknown",
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
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