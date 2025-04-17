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
  late String backendUrl; // Declare backendUrl with `late`

  GoogleMapController? _mapController;
  LatLng? _userLocation;
  String? errorMessage;
  Set<Marker> _markers = {};
  IOWebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    backendUrl = '$baseUrl/api/location/users-in-radius'; // Initialize here
    _fetchLocationWithTimeout();
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
        infoWindow: const InfoWindow(title: "Your Location"),
      ));
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
