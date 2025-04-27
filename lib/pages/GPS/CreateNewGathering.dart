import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CreateNewGathering extends ConsumerStatefulWidget {
  const CreateNewGathering({super.key});

  @override
  ConsumerState<CreateNewGathering> createState() => _CreateNewGatheringState();
}

class _CreateNewGatheringState extends ConsumerState<CreateNewGathering> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();
  
  // Form fields
  String _title = '';
  String _description = '';
  double _radius = 500.0;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endTime = DateTime.now().add(const Duration(hours: 2));
  LatLng? _selectedLocation;
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
    final accentColor = Theme.of(context).primaryColor;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100];

    return Scaffold(
      backgroundColor: background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            )
          : Stack(
              children: [
                // Freely movable map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ?? const LatLng(0, 0),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _getCurrentLocation();
                  },
                  onTap: (latLng) {
                    setState(() {
                      _selectedLocation = latLng;
                    });
                  },
                  markers: _selectedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('selected_location'),
                            position: _selectedLocation!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueAzure),
                          ),
                        }
                      : {},
                  circles: _selectedLocation != null
                      ? {
                          Circle(
                            circleId: const CircleId('gathering_radius'),
                            center: _selectedLocation!,
                            radius: _radius,
                            fillColor: accentColor.withOpacity(0.2),
                            strokeColor: accentColor.withOpacity(0.5),
                            strokeWidth: 2,
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
                // Form overlay
                DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.3,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Drag handle
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Title
                              Text(
                                'Create New Gathering',
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Simplified title field
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: TextStyle(color: foreground),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _title = value!,
                              ),
                              const SizedBox(height: 16),
                              // Simplified description field
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Description (optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                style: TextStyle(color: foreground),
                                maxLines: 3,
                                onSaved: (value) => _description = value ?? '',
                              ),
                              const SizedBox(height: 16),
                              // Radius slider
                              Card(
                                elevation: 0,
                                color: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gathering Radius: ${_radius.round()}m',
                                        style: TextStyle(
                                          color: foreground,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Slider(
                                        value: _radius,
                                        min: 50,
                                        max: 500,
                                        divisions: 9,
                                        label: '${_radius.round()}m',
                                        activeColor: accentColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _radius = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Start time picker
                              ListTile(
                                leading: Icon(Icons.event, color: accentColor),
                                title: Text(
                                  'Start Time',
                                  style: TextStyle(color: foreground),
                                ),
                                subtitle: Text(
                                  DateFormat('MMM dd, yyyy - hh:mm a').format(_startTime),
                                  style: TextStyle(color: foreground.withOpacity(0.7)),
                                ),
                                trailing: Icon(Icons.edit, color: accentColor),
                                onTap: () => _selectDateTime(context, true),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: Colors.white.withOpacity(0.1),
                              ),
                              const SizedBox(height: 8),
                              // End time picker
                              ListTile(
                                leading: Icon(Icons.event_available, color: accentColor),
                                title: Text(
                                  'End Time',
                                  style: TextStyle(color: foreground),
                                ),
                                subtitle: Text(
                                  DateFormat('MMM dd, yyyy - hh:mm a').format(_endTime),
                                  style: TextStyle(color: foreground.withOpacity(0.7)),
                                ),
                                trailing: Icon(Icons.edit, color: accentColor),
                                onTap: () => _selectDateTime(context, false),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: Colors.white.withOpacity(0.1),
                              ),
                              // Error message
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _submitForm,
                                  child: const Text(
                                    'Create Gathering',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation!),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not get current location';
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final initialDate = isStartTime ? _startTime : _endTime;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        setState(() {
          if (isStartTime) {
            _startTime = newDateTime;
            if (_endTime.isBefore(_startTime.add(const Duration(hours: 1)))) {
              _endTime = _startTime.add(const Duration(hours: 1));
            }
          } else {
            _endTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      if (_selectedLocation == null) {
        setState(() {
          _errorMessage = 'Please select a location on the map';
        });
        return;
      }
      
      if (_endTime.isBefore(_startTime.add(const Duration(minutes: 30)))) {
        setState(() {
          _errorMessage = 'Gathering must last at least 30 minutes';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final data = {
          'title': _title,
          'description': _description,
          'location': {
            'latitude': _selectedLocation!.latitude,
            'longitude': _selectedLocation!.longitude,
          },
          'radius': _radius.round(),
          'startTime': _startTime.toIso8601String(),
          'endTime': _endTime.toIso8601String(),
        };

        final response = await _apiClient.post('/api/gatherings', data);
        Navigator.of(context).pop(true);
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to create gathering';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}