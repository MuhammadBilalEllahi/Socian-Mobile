import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';

class MapMainPage extends StatefulWidget {
  const MapMainPage({super.key});

  @override
  _MapMainPageState createState() => _MapMainPageState();
}

class _MapMainPageState extends State<MapMainPage> {
  final String apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
  final String backendUrl = dotenv.env['BACKEND_URL'] ?? '';

  GoogleMapController? _mapController;
  LatLng? _userLocation;
  String? errorMessage;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  IOWebSocketChannel? _channel;
  double _radius = 500.0; // Default radius in meters
  int _userCountInRadius = 0;

  // Custom marker icons
  BitmapDescriptor? _userMarkerIcon; // Red for user
  BitmapDescriptor? _otherMarkerIcon; // Blue for others

  @override
  void initState() {
    super.initState();
    _setMarkerIcons(); // Set custom marker icons
    _fetchLocationWithTimeout();
  }

  // Function to set custom marker icons
  Future<void> _setMarkerIcons() async {
    _userMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    _otherMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
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
      _markers.add(Marker(
        markerId: const MarkerId("user_location"),
        position: _userLocation!,
        icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarker, // Red marker for user
        infoWindow: const InfoWindow(title: "Your Location"),
      ));
      _updateCircle();
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 15));
    _fetchUsersInRadius();
    _connectWebSocket();
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

  Future<void> _fetchUsersInRadius() async {
    if (_userLocation == null) return;

    final url = Uri.parse(
        "$backendUrl/api/location/users-in-radius?lat=${_userLocation!.latitude}&lng=${_userLocation!.longitude}&radius=$_radius");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _markers.clear();
          _markers.add(Marker(
            markerId: const MarkerId("user_location"),
            position: _userLocation!,
            icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarker, // Red marker for user
            infoWindow: const InfoWindow(title: "Your Location"),
          ));

          _userCountInRadius = data.length;
          for (var user in data) {
            _markers.add(
              Marker(
                markerId: MarkerId(user['id'].toString()),
                position: LatLng(user['latitude'], user['longitude']),
                icon: _otherMarkerIcon ?? BitmapDescriptor.defaultMarker, // Blue marker for others
                infoWindow: InfoWindow(title: user['name']),
              ),
            );
          }
        });
      } else {
        setState(() {
          errorMessage = "Failed to load users: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching users: $e";
      });
    }
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect(Uri.parse(backendUrl));
    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['event'] == 'attendeeLocationUpdate' && _isWithinRadius(data['latitude'], data['longitude'])) {
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(data['id'].toString()),
              position: LatLng(data['latitude'], data['longitude']),
              icon: _otherMarkerIcon ?? BitmapDescriptor.defaultMarker, // Blue marker for others
              infoWindow: InfoWindow(title: data['name']),
            ),
          );
          _userCountInRadius = _markers.length - 1; // Subtract user's own marker
        });
      }
    }, onError: (error) {
      setState(() {
        errorMessage = "WebSocket error: $error";
      });
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
                  ? Text(errorMessage!, style: const TextStyle(color: Colors.red))
                  : const CircularProgressIndicator(),
            ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  color: Colors.black,
                  child: Text(
                    "Users in radius: $_userCountInRadius",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Slider(
                  value: _radius,
                  min: 100,
                  max: 1000,
                  divisions: 20,
                  label: "${_radius.round()} meters",
                  onChanged: (value) {
                    setState(() {
                      _radius = value;
                      _updateCircle();
                      _fetchUsersInRadius();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchLocationWithTimeout,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _channel?.sink.close();
    super.dispose();
  }
}