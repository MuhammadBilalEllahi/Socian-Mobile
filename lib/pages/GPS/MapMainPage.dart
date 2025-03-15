  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:http/http.dart' as http;
  import 'package:geolocator/geolocator.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';

  class MapMainPage extends StatefulWidget {
    
    const MapMainPage({super.key});

    @override
    _MapMainPageState createState() => _MapMainPageState();
  }

  class _MapMainPageState extends State<MapMainPage> {
    final String apiKey = dotenv.env['MAPS_API_KEY'] ?? '';

    GoogleMapController? _mapController;
    LatLng? _userLocation;
    String? errorMessage;

    @override
    void initState() {
      super.initState();
      _fetchLocationWithTimeout();
    }

    Future<void> _fetchLocationWithTimeout() async {
      print("Starting location fetch...");
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
          print("Fetch failed: $e");
        });
      }
    }

    Future<void> _checkPermissionsAndFetchLocation() async {
      print("Checking location service...");
      bool serviceEnabled;

      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        print("Service check failed: $e");
        serviceEnabled = false;
      }

      if (!serviceEnabled) {
        print("Location services disabled");
        setState(() {
          errorMessage = "Location service is disabled";
        });
        return;
      }

      print("Checking permission...");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print("Requesting permission...");
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

      print("Getting device location...");
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );

        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          errorMessage = null;
          print("Location set: $_userLocation");
        });

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 15));
      } catch (e) {
        print("Device location failed: $e, trying IP fallback...");
        await _fetchIpBasedLocation();
      }
    }

    Future<void> _fetchIpBasedLocation() async {
      final url = Uri.parse(
          'https://www.gomaps.pro/geolocation/v1/geolocate?key=$apiKey');

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"considerIp": "true"}),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _userLocation = LatLng(data["location"]["lat"], data["location"]["lng"]);
            errorMessage = null;
            print("IP location set: $_userLocation");
          });

          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userLocation!, 15));
        } else {
          setState(() {
            errorMessage = "API Error: ${response.statusCode}";
            print("API error: $errorMessage");
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = "IP Location Error: $e";
          print("IP fetch failed: $e");
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      print("Building UI - Location: $_userLocation, Error: $errorMessage");

      return Scaffold(
        appBar: AppBar(title: const Text("User Location on Map")),
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
                  print("Map created");
                },
                markers: {
                  Marker(
                    markerId: const MarkerId("user_location"),
                    position: _userLocation!,
                    infoWindow: const InfoWindow(title: "Your Location"),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              )
            else
              Center(
                child: errorMessage != null
                    ? Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
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
      super.dispose();
    }
  }