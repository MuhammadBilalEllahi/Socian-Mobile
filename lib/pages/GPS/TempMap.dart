import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TempMap extends StatefulWidget {
  const TempMap({super.key});

  @override
  State<TempMap> createState() => _TempMapState();
}

class _TempMapState extends State<TempMap> {
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.455);
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _pGooglePlex,
        zoom: 13,
      ),
      markers: {
        Marker(
          markerId: MarkerId("_currentlocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: _pGooglePlex,
        ),
      },
    );
  }
}
