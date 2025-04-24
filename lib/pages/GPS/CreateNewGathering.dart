import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
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
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final muted = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Create New Gathering',
          style: TextStyle(
            color: foreground,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: foreground),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(foreground),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map for location selection
                    SizedBox(
                      height: 300,
                      child: GoogleMap(
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
                                ),
                              }
                            : {},
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
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
                    
                    // Description field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: border),
                        ),
                      ),
                      style: TextStyle(color: foreground),
                      maxLines: 3,
                      onSaved: (value) => _description = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    
                    // Radius slider
                    Text(
                      'Gathering Radius: ${_radius.round()}m',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: _radius,
                      min: 100,
                      max: 1000,
                      divisions: 18,
                      label: '${_radius.round()}m',
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Start time picker
                    ListTile(
                      title: Text(
                        'Start Time',
                        style: TextStyle(color: foreground),
                      ),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(_startTime),
                        style: TextStyle(color: foreground),
                      ),
                      trailing: Icon(Icons.edit, color: foreground),
                      onTap: () => _selectDateTime(context, true),
                    ),
                    
                    // End time picker
                    ListTile(
                      title: Text(
                        'End Time',
                        style: TextStyle(color: foreground),
                      ),
                      subtitle: Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(_endTime),
                        style: TextStyle(color: foreground),
                      ),
                      trailing: Icon(Icons.edit, color: foreground),
                      onTap: () => _selectDateTime(context, false),
                    ),
                    
                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    
                    // Submit button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: muted,
                          foregroundColor: foreground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: const Text('Create Gathering'),
                      ),
                    ),
                  ],
                ),
              ),
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
        _errorMessage = 'Could not get current location: ${e.toString()}';
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
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
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

        print("Sending gathering data: $data"); // Debug log

        // Use ApiClient to make the POST request
        final response = await _apiClient.post(
          '/api/gatherings',
          data,
        );

        print("Response data: $response"); // Debug log

        // If successful, pop the screen
        Navigator.of(context).pop(true);
      } catch (e) {
        print("Error creating gathering: $e"); // Debug log
        setState(() {
          _errorMessage = e.toString();
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
