import 'dart:convert';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';

class LiveLocation extends StatefulWidget {
  const LiveLocation({super.key});

  @override
  State<LiveLocation> createState() => _LiveLocationState();
}

class _LiveLocationState extends State<LiveLocation> {
  final String apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
  final String baseUrl = ApiConstants.baseUrl;
  late String backendUrl;
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  String? errorMessage;
  Set<Marker> _markers = {};
  IOWebSocketChannel? _channel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    backendUrl = '$baseUrl/api/location/users-in-radius';
    _fetchLocationWithTimeout();
  }

  Future<void> _fetchLocationWithTimeout() async {
    setState(() => _isLoading = true);
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
      _markers.add(Marker(
        markerId: const MarkerId("user_location"),
        position: _userLocation!,
        infoWindow: const InfoWindow(title: "Your Location"),
      ));
      _isLoading = false;
    });

    _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 15));
    _fetchAttendees();
    _connectWebSocket();
  }

  Future<void> _fetchAttendees() async {
    final url = Uri.parse("$backendUrl/api/event/attendees");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          for (var attendee in data) {
            _markers.add(
              Marker(
                markerId: MarkerId(attendee['id'].toString()),
                position: LatLng(attendee['latitude'], attendee['longitude']),
                infoWindow: InfoWindow(title: attendee['name']),
              ),
            );
          }
        });
      } else {
        setState(() {
          errorMessage = "Failed to load attendees: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching attendees: $e";
      });
    }
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect(Uri.parse(backendUrl));

    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(data['id'].toString()),
            position: LatLng(data['latitude'], data['longitude']),
            infoWindow: InfoWindow(title: data['name']),
          ),
        );
      });
    }, onError: (error) {
      setState(() {
        errorMessage = "WebSocket error: $error";
      });
    });
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
          'Live Location',
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
                    'Fetching your location...',
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
          if (_markers.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  '${_markers.length - 1} users nearby',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
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
    _channel?.sink.close();
    super.dispose();
  }
}
