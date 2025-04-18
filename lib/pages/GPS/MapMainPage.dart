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
  final String baseUrl = ApiConstants.portUrl;
  bool _isDropdownOpen = false;

  GoogleMapController? _mapController;
  LatLng? _userLocation;
  String? errorMessage;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  IO.Socket? _socket;
  double _radius = 50.0;
  int _userCountInRadius = 0;

  BitmapDescriptor? _userMarkerIcon;
  BitmapDescriptor? _otherMarkerIcon;

  bool _isSharingLocation = false;
  bool _isInRadius = false;

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
        final auth = ref.read(authProvider);
        final currentUserId = auth.user?['id'].toString();

        if (data != null &&
            data['id'].toString() != currentUserId &&
            _isWithinRadius(data['latitude'], data['longitude'])) {
          setState(() {
            final markerId = data['id'].toString();
            _markers.removeWhere((m) => m.markerId.value == markerId);
            _markers.add(
              Marker(
                markerId: MarkerId(markerId),
                position: LatLng(data['latitude'], data['longitude']),
                icon: _otherMarkerIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(title: data['name'] ?? "Unknown"),
              ),
            );
            _userCountInRadius = _markers.length;
          });
        }
      });

      _socket?.on('attendeesList', (data) {
        final auth = ref.read(authProvider);
        final currentUserId = auth.user?['id'].toString();

        if (data is List) {
          setState(() {
            _markers.removeWhere((m) => m.markerId.value != "user_location");

            for (var user in data) {
              if (user['id'].toString() != currentUserId &&
                  _isWithinRadius(user['latitude'], user['longitude'])) {
                _markers.add(
                  Marker(
                    markerId: MarkerId(user['id'].toString()),
                    position: LatLng(user['latitude'], user['longitude']),
                    icon: _otherMarkerIcon ?? BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(title: user['name'] ?? "Unknown"),
                  ),
                );
              }
            }

            _userCountInRadius = _markers.length;
          });
        }
      });

      _socket?.on('error', (error) => print('Socket error: $error'));
      _socket?.on(
          'disconnect', (_) => print('Disconnected from Socket.IO server'));
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  Future<void> _setMarkerIcons() async {
    _userMarkerIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    _otherMarkerIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  Future<void> _fetchLocationWithTimeout() async {
    try {
      await _checkPermissionsAndFetchLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception("Location fetch timed out");
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
    }
  }

  Future<void> _checkPermissionsAndFetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage = "Location service is disabled";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage = "Location permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage = "Location permissions permanently denied";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _isInRadius = _isWithinRadius(position.latitude, position.longitude);
      _updateCircle();
    });

    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 15));
  }

  void _toggleLocationSharing() {
    if (_userLocation == null) return;

    final auth = ref.read(authProvider);

    setState(() {
      _isSharingLocation = !_isSharingLocation;

      if (_isSharingLocation) {
        _markers.add(Marker(
          markerId: const MarkerId("user_location"),
          position: _userLocation!,
          icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: auth.user?['name'] ?? "Your Location"),
        ));
        _sendLocationUpdate();
        _requestNearbyAttendees();
      } else {
        _markers.removeWhere((m) => m.markerId.value == "user_location");
        _socket?.emit('stopSharing', {
          'userId': auth.user?['id'],
        });
      }
    });
  }

  void _sendLocationUpdate() {
    if (_userLocation == null || _socket == null || !_socket!.connected) return;

    final auth = ref.read(authProvider);
    final userData = {
      'userId': auth.user?['id'] ?? 'default_user_id',
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
    final auth = ref.watch(authProvider);

    return Scaffold(
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
          else
            Center(
              child: errorMessage != null
                  ? Text(errorMessage!,
                      style: const TextStyle(color: Colors.red))
                  : const CircularProgressIndicator(),
            ),

          // Top Status Panel
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Users in radius: $_userCountInRadius",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _isInRadius ? _toggleLocationSharing : null,
                    icon: Icon(_isSharingLocation
                        ? Icons.location_off
                        : Icons.location_on),
                    label: Text(_isSharingLocation
                        ? "Stop Sharing"
                        : "Share My Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isInRadius ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      disabledForegroundColor: Colors.white70,
                    ),
                  ),
                  Slider(
                      value: _radius,
                      min: 10,
                      max: 100,
                      divisions: 20,
                      label: "${_radius.round()} meters",
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                          _updateCircle();
                        });

                        if (_isSharingLocation) {
                          _sendLocationUpdate(); // Notify server of radius change
                          _requestNearbyAttendees(); // Ask server for new nearby users
                        }
                      }),
                ],
              ),
            ),
          ),

          
          // Left Panel - Nearby Users as Dropdown
          Positioned(
            top: 250,
            left: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 180,
              height: _isDropdownOpen ? 300 : 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDropdownOpen = !_isDropdownOpen;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Nearby Users",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Icon(
                            _isDropdownOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isDropdownOpen) const Divider(),
                  if (_isDropdownOpen)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _markers.length,
                        itemBuilder: (context, index) {
                          final marker = _markers.elementAt(index);
                          if (marker.markerId.value == "user_location")
                            return const SizedBox();
                          return Card(
                            elevation: 1,
                            child: ListTile(
                              title: Text(
                                marker.infoWindow.title ?? "Unknown",
                                style: const TextStyle(fontSize: 12),
                              ),
                              dense: true,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        child: FloatingActionButton(
          onPressed: _fetchLocationWithTimeout,
          child: const Icon(Icons.refresh),
        ),
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
