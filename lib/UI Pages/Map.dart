import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OSM Map with Current Location")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: _currentPosition ?? LatLng(0.0, 0.0),
          minZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            // subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 80.0,
                height: 80.0,
                child: Icon(Icons.location_pin, size: 40,color: Colors.red,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}














