import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'location_text_selector.dart';
import 'location_search_modal.dart';
import '../CreatePost.dart';

class LocationSection extends StatefulWidget {
  final PostType postType;
  final String? selectedLocation;
  final Position? currentPosition;
  final Function(String?) onLocationSelected;
  final Function() onLocationCleared;
  final Function(String) onSearchQueryChanged;
  final Function(Position?) onMapLocationSelected;

  const LocationSection({
    super.key,
    required this.postType,
    required this.selectedLocation,
    required this.currentPosition,
    required this.onLocationSelected,
    required this.onLocationCleared,
    required this.onSearchQueryChanged,
    required this.onMapLocationSelected,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  bool _showMap = false;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  String? _mapSelectedAddress;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPosition != widget.currentPosition) {
      _updateMarkers();
      if (widget.currentPosition != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              widget.currentPosition!.latitude,
              widget.currentPosition!.longitude,
            ),
          ),
        );
      }
    }
  }

  void _updateMarkers() {
    if (widget.currentPosition != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          ),
          infoWindow: InfoWindow(
            title: _mapSelectedAddress ?? 'Selected Location',
          ),
        ),
      };
    }
  }

  void _showLocationTextSelector() {
    showDialog(
      context: context,
      builder: (context) => LocationTextSelector(
        selectedLocation: widget.selectedLocation,
        onLocationSelected: widget.onLocationSelected,
      ),
    );
  }

  void _showLocationSearchModal() {
    showDialog(
      context: context,
      builder: (context) => LocationSearchModal(
        onLocationSelected: (location) {
          if (location != null) {
            // TODO: Convert location to coordinates using Geocoding
            widget.onMapLocationSelected(
              Position(
                latitude: 31.5497, // Default to Lahore
                longitude: 74.3436,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                altitudeAccuracy: 0,
                headingAccuracy: 0,
                isMocked: false,
              ),
            );
            setState(() {
              _mapSelectedAddress = location;
            });
          }
        },
        onSearchQueryChanged: widget.onSearchQueryChanged,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      widget.onMapLocationSelected(position);
      // TODO: Get address from coordinates using Geocoding
      setState(() {
        _mapSelectedAddress = 'Current Location';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only show map feature for society posts
        if (widget.postType == PostType.society) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showLocationSearchModal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 20,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _mapSelectedAddress ?? 'Search location...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _mapSelectedAddress != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showMap = !_showMap;
                    });
                  },
                  icon: Icon(
                    _showMap ? Icons.map : Icons.map_outlined,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          if (_showMap) ...[
            const SizedBox(height: 8),
            Container(
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      widget.currentPosition?.latitude ?? 31.5497,
                      widget.currentPosition?.longitude ?? 74.3436,
                    ),
                    zoom: 13,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (latLng) {
                    setState(() {
                      _markers = {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: latLng,
                          infoWindow: const InfoWindow(title: 'Selected Location'),
                        ),
                      };
                    });
                    widget.onMapLocationSelected(
                      Position(
                        latitude: latLng.latitude,
                        longitude: latLng.longitude,
                        timestamp: DateTime.now(),
                        accuracy: 0,
                        altitude: 0,
                        heading: 0,
                        speed: 0,
                        speedAccuracy: 0,
                        altitudeAccuracy: 0,
                        headingAccuracy: 0,
                        isMocked: false,
                      ),
                    );
                    // TODO: Get address from coordinates using Geocoding
                    setState(() {
                      _mapSelectedAddress = 'Selected Location';
                    });
                  },
                ),
              ),
            ),
            if (_mapSelectedAddress != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _mapSelectedAddress!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ],
    );
  }
} 