// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:socian/shared/services/api_client.dart';

// class CreateNewGathering2 extends ConsumerStatefulWidget {
//   const CreateNewGathering2({super.key});

//   @override
//   ConsumerState<CreateNewGathering2> createState() =>
//       _CreateNewGathering2State();
// }

// class _CreateNewGathering2State extends ConsumerState<CreateNewGathering2> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiClient _apiClient = ApiClient();

//   // Form fields
//   String _title = '';
//   String _description = '';
//   double _radius = 500.0;
//   DateTime _startTime = DateTime.now();
//   DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
//   LatLng? _selectedLocation;
//   String? _selectedSocietyId;
//   List<Map<String, String>> _moderatedSocieties = [];

//   // UI state
//   bool _isLoading = false;
//   bool _isFetchingSocieties = true;
//   String? _errorMessage;
//   GoogleMapController? _mapController;

//   @override
//   void initState() {
//     super.initState();
//     _fetchModeratedSocieties();
//   }

//   Future<void> _fetchModeratedSocieties() async {
//     setState(() {
//       _isFetchingSocieties = true;
//       _errorMessage = null;
//     });

//     try {
//       final response = await _apiClient.get('/api/user/moderated-societies');
//       log('Moderated societies response: $response');

//       if (response == null || response is! List) {
//         setState(() {
//           _errorMessage = 'Invalid response from server';
//           _isFetchingSocieties = false;
//           _moderatedSocieties = [];
//         });
//         return;
//       }

//       final societies = List<Map<String, dynamic>>.from(response);
//       setState(() {
//         _moderatedSocieties = societies
//             .map((s) => {
//                   '_id': s['_id']?.toString() ?? '',
//                   'name': s['name']?.toString() ?? 'Unknown Society',
//                 })
//             .toList();
//         if (_moderatedSocieties.isNotEmpty) {
//           _selectedSocietyId = _moderatedSocieties.first['_id'];
//         }
//         _isFetchingSocieties = false;
//       });
//     } catch (e, stackTrace) {
//       log('Error fetching moderated societies: $e', stackTrace: stackTrace);
//       setState(() {
//         _errorMessage = 'Failed to load societies: $e';
//         _isFetchingSocieties = false;
//         _moderatedSocieties = [];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background =
//         isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
//     final foreground =
//         isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
//     final muted =
//         isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
//     final mutedForeground =
//         isDarkMode ? const Color(0xFFA3A3A3) : const Color(0xFF737373);
//     final border =
//         isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
//     final accent =
//         isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA);
//     final primaryColor =
//         isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
//     final cardBackground =
//         isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
//     final cardBorder =
//         isDarkMode ? const Color(0xFF262626) : const Color(0xFFE5E5E5);
//     final cardShadow = isDarkMode
//         ? Colors.black.withOpacity(0.1)
//         : Colors.black.withOpacity(0.05);

//     return Scaffold(
//       backgroundColor: background,
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
//               ),
//             )
//           : Stack(
//               children: [
//                 // Freely movable map
//                 GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: _selectedLocation ?? const LatLng(0, 0),
//                     zoom: 14,
//                   ),
//                   onMapCreated: (controller) {
//                     _mapController = controller;
//                     _getCurrentLocation();
//                   },
//                   onTap: (latLng) {
//                     setState(() {
//                       _selectedLocation = latLng;
//                     });
//                   },
//                   markers: _selectedLocation != null
//                       ? {
//                           Marker(
//                             markerId: const MarkerId('selected_location'),
//                             position: _selectedLocation!,
//                             icon: BitmapDescriptor.defaultMarkerWithHue(
//                                 BitmapDescriptor.hueAzure),
//                           ),
//                         }
//                       : {},
//                   circles: _selectedLocation != null
//                       ? {
//                           Circle(
//                             circleId: const CircleId('gathering_radius'),
//                             center: _selectedLocation!,
//                             radius: _radius,
//                             fillColor: primaryColor.withOpacity(0.1),
//                             strokeColor: primaryColor.withOpacity(0.3),
//                             strokeWidth: 2,
//                           ),
//                         }
//                       : {},
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                   zoomControlsEnabled: false,
//                 ),
//                 // Form overlay
//                 DraggableScrollableSheet(
//                   initialChildSize: 0.6,
//                   minChildSize: 0.3,
//                   maxChildSize: 0.95,
//                   builder: (context, scrollController) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         color: cardBackground,
//                         borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(16),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: cardShadow,
//                             blurRadius: 4,
//                             offset: const Offset(0, -2),
//                           ),
//                         ],
//                       ),
//                       child: _isFetchingSocieties
//                           ? const Center(child: CircularProgressIndicator())
//                           : _moderatedSocieties.isEmpty
//                               ? SingleChildScrollView(
//                                   controller: scrollController,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         const SizedBox(height: 16),
//                                         Icon(
//                                           Icons.lock_outline,
//                                           size: 48,
//                                           color: mutedForeground,
//                                         ),
//                                         const SizedBox(height: 16),
//                                         Text(
//                                           'Not Allowed',
//                                           style: TextStyle(
//                                             color: foreground,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           'You need to be a moderator of a society to create gatherings and your society should have atleast 25 members',
//                                           style: TextStyle(
//                                             color: mutedForeground,
//                                             fontSize: 14,
//                                             letterSpacing: -0.3,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                         const SizedBox(height: 24),
//                                         ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: primaryColor,
//                                             foregroundColor: background,
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 24, vertical: 12),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(6),
//                                             ),
//                                             elevation: 0,
//                                           ),
//                                           onPressed: _fetchModeratedSocieties,
//                                           child: const Text(
//                                             'Retry',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         if (_errorMessage != null)
//                                           Text(
//                                             _errorMessage!,
//                                             style: TextStyle(
//                                               color: Colors.red[400],
//                                               fontSize: 14,
//                                               letterSpacing: -0.3,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                               : SingleChildScrollView(
//                                   controller: scrollController,
//                                   padding: const EdgeInsets.all(16),
//                                   child: Form(
//                                     key: _formKey,
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // Drag handle
//                                         Center(
//                                           child: Container(
//                                             width: 40,
//                                             height: 4,
//                                             margin: const EdgeInsets.only(
//                                                 bottom: 16),
//                                             decoration: BoxDecoration(
//                                               color: mutedForeground,
//                                               borderRadius:
//                                                   BorderRadius.circular(2),
//                                             ),
//                                           ),
//                                         ),
//                                         // Title
//                                         Text(
//                                           'Create New Gathering',
//                                           style: TextStyle(
//                                             color: foreground,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w500,
//                                             letterSpacing: -0.5,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 24),
//                                         // Society selection
//                                         DropdownButtonFormField<String>(
//                                           decoration: InputDecoration(
//                                             labelText: 'Select Society',
//                                             labelStyle: TextStyle(
//                                               color: mutedForeground,
//                                               fontSize: 14,
//                                               letterSpacing: -0.3,
//                                             ),
//                                             prefixIcon: Icon(
//                                               Icons.group,
//                                               color: mutedForeground,
//                                               size: 20,
//                                             ),
//                                             filled: true,
//                                             fillColor: accent,
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide(
//                                                 color: primaryColor,
//                                                 width: 1.5,
//                                               ),
//                                             ),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                                     vertical: 14,
//                                                     horizontal: 16),
//                                           ),
//                                           dropdownColor: cardBackground,
//                                           value: _selectedSocietyId,
//                                           items: _moderatedSocieties
//                                               .map((society) {
//                                             return DropdownMenuItem<String>(
//                                               value: society['_id'],
//                                               child: Text(
//                                                 society['name']!,
//                                                 style: TextStyle(
//                                                   color: foreground,
//                                                   fontSize: 14,
//                                                   letterSpacing: -0.3,
//                                                 ),
//                                               ),
//                                             );
//                                           }).toList(),
//                                           onChanged: (value) {
//                                             setState(() {
//                                               _selectedSocietyId = value;
//                                             });
//                                           },
//                                           validator: (value) {
//                                             if (value == null ||
//                                                 value.isEmpty) {
//                                               return 'Please select a society';
//                                             }
//                                             return null;
//                                           },
//                                           menuMaxHeight: 200,
//                                           style: TextStyle(
//                                             color: foreground,
//                                             fontSize: 14,
//                                           ),
//                                           icon: Icon(
//                                             Icons.arrow_drop_down,
//                                             color: mutedForeground,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         // Title field
//                                         TextFormField(
//                                           decoration: InputDecoration(
//                                             labelText: 'Title',
//                                             labelStyle: TextStyle(
//                                               color: mutedForeground,
//                                               fontSize: 14,
//                                               letterSpacing: -0.3,
//                                             ),
//                                             filled: true,
//                                             fillColor: accent,
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide(
//                                                   color: primaryColor,
//                                                   width: 1.5),
//                                             ),
//                                           ),
//                                           style: TextStyle(
//                                             color: foreground,
//                                             fontSize: 14,
//                                             letterSpacing: -0.3,
//                                           ),
//                                           validator: (value) {
//                                             if (value == null ||
//                                                 value.trim().isEmpty) {
//                                               return 'Please enter a title';
//                                             }
//                                             return null;
//                                           },
//                                           onSaved: (value) =>
//                                               _title = value!.trim(),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         // Description field
//                                         TextFormField(
//                                           decoration: InputDecoration(
//                                             labelText: 'Description',
//                                             labelStyle: TextStyle(
//                                               color: mutedForeground,
//                                               fontSize: 14,
//                                               letterSpacing: -0.3,
//                                             ),
//                                             filled: true,
//                                             fillColor: accent,
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             enabledBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                             focusedBorder: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                               borderSide: BorderSide(
//                                                   color: primaryColor,
//                                                   width: 1.5),
//                                             ),
//                                           ),
//                                           style: TextStyle(
//                                             color: foreground,
//                                             fontSize: 14,
//                                             letterSpacing: -0.3,
//                                           ),
//                                           maxLines: 3,
//                                           onSaved: (value) => _description =
//                                               value?.trim() ?? '',
//                                         ),
//                                         const SizedBox(height: 16),
//                                         // Radius slider
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             color: accent,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: cardShadow,
//                                                 blurRadius: 2,
//                                                 offset: const Offset(0, 1),
//                                               ),
//                                             ],
//                                           ),
//                                           padding: const EdgeInsets.all(16),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'Gathering Radius: ${_radius.round()}m',
//                                                 style: TextStyle(
//                                                   color: foreground,
//                                                   fontSize: 14,
//                                                   fontWeight: FontWeight.w500,
//                                                   letterSpacing: -0.3,
//                                                 ),
//                                               ),
//                                               Slider(
//                                                 value: _radius,
//                                                 min: 50,
//                                                 max: 500,
//                                                 divisions: 9,
//                                                 label: '${_radius.round()}m',
//                                                 activeColor: primaryColor,
//                                                 inactiveColor: mutedForeground,
//                                                 onChanged: (value) {
//                                                   setState(() {
//                                                     _radius = value;
//                                                   });
//                                                 },
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(height: 16),
//                                         // Start time picker
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             color: accent,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: cardShadow,
//                                                 blurRadius: 2,
//                                                 offset: const Offset(0, 1),
//                                               ),
//                                             ],
//                                           ),
//                                           child: ListTile(
//                                             leading: Icon(Icons.event,
//                                                 color: primaryColor),
//                                             title: Text(
//                                               'Start Time',
//                                               style: TextStyle(
//                                                 color: foreground,
//                                                 fontSize: 14,
//                                                 letterSpacing: -0.3,
//                                               ),
//                                             ),
//                                             subtitle: Text(
//                                               DateFormat(
//                                                       'MMM dd, yyyy - hh:mm a')
//                                                   .format(_startTime),
//                                               style: TextStyle(
//                                                 color: mutedForeground,
//                                                 fontSize: 14,
//                                                 letterSpacing: -0.3,
//                                               ),
//                                             ),
//                                             trailing: Icon(Icons.edit,
//                                                 color: primaryColor),
//                                             onTap: () =>
//                                                 _selectDateTime(context, true),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         // End time picker
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             color: accent,
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: cardShadow,
//                                                 blurRadius: 2,
//                                                 offset: const Offset(0, 1),
//                                               ),
//                                             ],
//                                           ),
//                                           child: ListTile(
//                                             leading: Icon(Icons.event_available,
//                                                 color: primaryColor),
//                                             title: Text(
//                                               'End Time',
//                                               style: TextStyle(
//                                                 color: foreground,
//                                                 fontSize: 14,
//                                                 letterSpacing: -0.3,
//                                               ),
//                                             ),
//                                             subtitle: Text(
//                                               DateFormat(
//                                                       'MMM dd, yyyy - hh:mm a')
//                                                   .format(_endTime),
//                                               style: TextStyle(
//                                                 color: mutedForeground,
//                                                 fontSize: 14,
//                                                 letterSpacing: -0.3,
//                                               ),
//                                             ),
//                                             trailing: Icon(Icons.edit,
//                                                 color: primaryColor),
//                                             onTap: () =>
//                                                 _selectDateTime(context, false),
//                                           ),
//                                         ),
//                                         // Error message
//                                         if (_errorMessage != null)
//                                           Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 16),
//                                             child: Text(
//                                               _errorMessage!,
//                                               style: TextStyle(
//                                                 color: Colors.red[400],
//                                                 fontSize: 14,
//                                                 letterSpacing: -0.3,
//                                               ),
//                                             ),
//                                           ),
//                                         const SizedBox(height: 24),
//                                         // Submit button
//                                         SizedBox(
//                                           width: double.infinity,
//                                           child: ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: primaryColor,
//                                               foregroundColor: background,
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 12),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               elevation: 2,
//                                             ),
//                                             onPressed:
//                                                 _isLoading ? null : _submitForm,
//                                             child: _isLoading
//                                                 ? const SizedBox(
//                                                     width: 20,
//                                                     height: 20,
//                                                     child:
//                                                         CircularProgressIndicator(
//                                                       color: Colors.white,
//                                                       strokeWidth: 2,
//                                                     ),
//                                                   )
//                                                 : const Text(
//                                                     'Create Gathering',
//                                                     style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                       letterSpacing: -0.3,
//                                                     ),
//                                                   ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//     );
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition();
//       setState(() {
//         _selectedLocation = LatLng(position.latitude, position.longitude);
//       });
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLng(_selectedLocation!),
//       );
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Could not get current location';
//       });
//     }
//   }

// Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
//   final now = DateTime.now();
//   final initialDate = isStartTime ? _startTime : _endTime;
//   final pickedDate = await showDatePicker(
//     context: context,
//     initialDate: initialDate.isBefore(now) ? now : initialDate,
//     firstDate: now,
//     lastDate: DateTime.now().add(const Duration(days: 365)),
//     builder: (context, child) {
//       return Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white
//                 : Colors.black,
//             onPrimary: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.black
//                 : Colors.white,
//             onSurface: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white
//                 : Colors.black,
//           ),
//         ),
//         child: child!,
//       );
//     },
//   );

//   if (pickedDate != null) {
//     final pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.fromDateTime(initialDate),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: ColorScheme.light(
//                 primary: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.white
//                     : Colors.black,
//                 onPrimary: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.black
//                     : Colors.white,
//                 onSurface: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.white
//                     : Colors.black,
//               ),
//             ),
//             child: child!,
//           );
//         });

//     if (pickedTime != null) {
//       final newDateTime = DateTime(
//         pickedDate.year,
//         pickedDate.month,
//         pickedDate.day,
//         pickedTime.hour,
//         pickedTime.minute,
//       );

//       setState(() {
//         if (isStartTime) {
//           _startTime = newDateTime;
//           if (_endTime
//               .isBefore(_startTime.add(const Duration(minutes: 30)))) {
//             _endTime = _startTime.add(const Duration(minutes: 30));
//           } else if (_endTime.difference(_startTime).inHours > 5) {
//             _endTime = _startTime.add(const Duration(hours: 5));
//           }
//         } else {
//           _endTime = newDateTime;
//         }
//       });
//     }
//   }
// }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       final now = DateTime.now();

//       if (_startTime.isBefore(now)) {
//         setState(() {
//           _errorMessage = 'Start time cannot be in the past';
//         });
//         return;
//       }

//       if (_selectedLocation == null) {
//         setState(() {
//           _errorMessage = 'Please select a location on the map';
//         });
//         return;
//       }

//       if (_endTime.isBefore(_startTime.add(const Duration(minutes: 30)))) {
//         setState(() {
//           _errorMessage = 'Gathering must last at least 30 minutes';
//         });
//         return;
//       }

//       if (_endTime.difference(_startTime).inHours > 5) {
//         setState(() {
//           _errorMessage = 'Gathering cannot exceed 5 hours';
//         });
//         return;
//       }

//       if (_moderatedSocieties.isEmpty || _selectedSocietyId == null) {
//         setState(() {
//           _errorMessage = 'You must be a moderator to create a gathering';
//         });
//         return;
//       }

//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       try {
//         final data = {
//           'title': _title,
//           'description': _description,
//           'location': {
//             'latitude': _selectedLocation!.latitude,
//             'longitude': _selectedLocation!.longitude,
//           },
//           'radius': _radius.round(),
//           'startTime': _startTime.toIso8601String(),
//           'endTime': _endTime.toIso8601String(),
//           'societyId': _selectedSocietyId,
//         };

//         log('Create Gathering Payload: $data');

//         await _apiClient.post('/api/gatherings', data);

//         // Check if widget is still mounted after async operation
//         if (!mounted) {
//           log('Widget is no longer mounted after API call');
//           return;
//         }

//         // Use a local context to avoid potential issues
//         final scaffoldMessenger = ScaffoldMessenger.of(context);
//         final navigator = Navigator.of(context);

//         scaffoldMessenger.showSnackBar(
//           const SnackBar(content: Text('Gathering created successfully')),
//         );

//         // Delay navigation to ensure SnackBar is visible
//         await Future.delayed(const Duration(seconds: 1));

//         if (mounted) {
//           navigator.pop();
//         }
//       } catch (e, stackTrace) {
//         log('Error creating gathering: $e', stackTrace: stackTrace);
//         if (mounted) {
//           setState(() {
//             _errorMessage = 'Failed to create gathering. Please try again.';
//             _isLoading = false;
//           });
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _mapController?.dispose();
//     super.dispose();
//   }
// }





















import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:socian/shared/services/api_client.dart';
import 'package:socian/features/auth/providers/auth_provider.dart';

class CreateNewGathering2 extends ConsumerStatefulWidget {
  const CreateNewGathering2({super.key});

  @override
  ConsumerState<CreateNewGathering2> createState() =>
      _CreateNewGathering2State();
}

class _CreateNewGathering2State extends ConsumerState<CreateNewGathering2> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  // Form fields
  String _title = '';
  String _description = '';
  double _radius = 500.0;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  LatLng? _selectedLocation;
  String? _selectedSocietyId;
  List<Map<String, String>> _moderatedSocieties = [];

  // UI state
  bool _isLoading = false;
  bool _isFetchingSocieties = true;
  String? _errorMessage;
  GoogleMapController? _mapController;

  // Map restriction parameters
  static const LatLng _comsatsLahore = LatLng(31.4027291, 74.2126438);
  static const LatLng _ituLahore = LatLng(31.4759632, 74.3428525);
  static const double _restrictionRadius = 1000.0; // 1km radius
  static const double _minZoomLevel = 14.0;
  static const double _maxZoomLevel = 18.0;

  // Debounce timer for camera updates
  Timer? _debounceTimer;

  // User university and campus
  String? _userUniversity;
  String? _userCampus;

  LatLngBounds? get _restrictedBounds {
    if (_userUniversity == 'Comsats' && _userCampus?.contains('Lahore') == true) {
      const double kmPerDegree = 111319.9; // Approximate meters per degree latitude
      final double latDiff = _restrictionRadius / kmPerDegree;
      final double lngDiff = _restrictionRadius /
          (kmPerDegree * cos(_comsatsLahore.latitude * pi / 180));
      return LatLngBounds(
        southwest: LatLng(
          _comsatsLahore.latitude - latDiff,
          _comsatsLahore.longitude - lngDiff,
        ),
        northeast: LatLng(
          _comsatsLahore.latitude + latDiff,
          _comsatsLahore.longitude + lngDiff,
        ),
      );
    } else if (_userUniversity == 'ITU' && _userCampus?.contains('Lahore') == true) {
      const double kmPerDegree = 111319.9;
      final double latDiff = _restrictionRadius / kmPerDegree;
      final double lngDiff = _restrictionRadius /
          (kmPerDegree * cos(_ituLahore.latitude * pi / 180));
      return LatLngBounds(
        southwest: LatLng(
          _ituLahore.latitude - latDiff,
          _ituLahore.longitude - lngDiff,
        ),
        northeast: LatLng(
          _ituLahore.latitude + latDiff,
          _ituLahore.longitude + lngDiff,
        ),
      );
    }
    return null; // No bounds for other universities
  }

  @override
  void initState() {
    super.initState();
    _fetchModeratedSocieties();
    _loadUserDetails();
  }

  void _loadUserDetails() {
    final auth = ref.read(authProvider);
    if (auth.user == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }
    setState(() {
      _userUniversity = auth.user?['university']?['universityId']?['name']?.toString();
      _userCampus = auth.user?['university']?['campusId']?['name']?.toString();
    });
    _getCurrentLocation();
  }

  Future<void> _fetchModeratedSocieties() async {
    setState(() {
      _isFetchingSocieties = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get('/api/user/moderated-societies');
      if (response == null || response is! List) {
        setState(() {
          _errorMessage = 'Invalid response from server';
          _isFetchingSocieties = false;
          _moderatedSocieties = [];
        });
        return;
      }

      final societies = List<Map<String, dynamic>>.from(response);
      setState(() {
        _moderatedSocieties = societies
            .map((s) => {
                  '_id': s['_id']?.toString() ?? '',
                  'name': s['name']?.toString() ?? 'Unknown Society',
                })
            .toList();
        if (_moderatedSocieties.isNotEmpty) {
          _selectedSocietyId = _moderatedSocieties.first['_id'];
        }
        _isFetchingSocieties = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Failed to load societies: $e';
        _isFetchingSocieties = false;
        _moderatedSocieties = [];
      });
    }
  }

  // Check if a LatLng is within the restricted bounds
  bool _isWithinBounds(LatLng position) {
    final bounds = _restrictedBounds;
    if (bounds == null) return true; // No restrictions for other universities
    return position.latitude >= bounds.southwest.latitude &&
        position.latitude <= bounds.northeast.latitude &&
        position.longitude >= bounds.southwest.longitude &&
        position.longitude <= bounds.northeast.longitude;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final foreground =
        isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final muted =
        isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final mutedForeground =
        isDarkMode ? const Color(0xFFA3A3A3) : const Color(0xFF737373);
    final primaryColor =
        isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final cardBackground =
        isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final cardShadow = isDarkMode
        ? Colors.black.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: background,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation ??
                        (_userUniversity == 'Comsats' &&
                                _userCampus?.contains('Lahore') == true
                            ? _comsatsLahore
                            : _userUniversity == 'ITU' &&
                                    _userCampus?.contains('Lahore') == true
                                ? _ituLahore
                                : const LatLng(0, 0)),
                    zoom: _minZoomLevel,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (latLng) {
                    if (_isWithinBounds(latLng)) {
                      setState(() {
                        _selectedLocation = latLng;
                        _errorMessage = null;
                      });
                    } else {
                      setState(() {
                        _errorMessage =
                            'Selected location is outside the allowed area';
                      });
                    }
                  },
                  onCameraMove: (_userUniversity == 'Comsats' &&
                              _userCampus?.contains('Lahore') == true) ||
                          (_userUniversity == 'ITU' &&
                              _userCampus?.contains('Lahore') == true)
                      ? (CameraPosition position) {
                          if (!_isWithinBounds(position.target)) {
                            _debounceTimer?.cancel();
                            _debounceTimer =
                                Timer(const Duration(milliseconds: 300), () {
                              if (mounted && _mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: _userUniversity == 'Comsats' &&
                                              _userCampus?.contains('Lahore') ==
                                                  true
                                          ? _comsatsLahore
                                          : _ituLahore,
                                      zoom: position.zoom
                                          .clamp(_minZoomLevel, _maxZoomLevel),
                                    ),
                                  ),
                                );
                              }
                            });
                          }
                        }
                      : null,
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
                            fillColor: primaryColor.withOpacity(0.1),
                            strokeColor: primaryColor.withOpacity(0.3),
                            strokeWidth: 2,
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  minMaxZoomPreference:
                      const MinMaxZoomPreference(_minZoomLevel, _maxZoomLevel),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.3,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cardShadow,
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: _isFetchingSocieties
                          ? const Center(child: CircularProgressIndicator())
                          : _moderatedSocieties.isEmpty
                              ? SingleChildScrollView(
                                  controller: scrollController,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 16),
                                        Icon(
                                          Icons.lock_outline,
                                          size: 48,
                                          color: mutedForeground,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Not Allowed',
                                          style: TextStyle(
                                            color: foreground,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'You need to be a moderator of a society to create gatherings and your society should have at least 25 members',
                                          style: TextStyle(
                                            color: mutedForeground,
                                            fontSize: 14,
                                            letterSpacing: -0.3,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: background,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: _fetchModeratedSocieties,
                                          child: const Text(
                                            'Retry',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (_errorMessage != null)
                                          Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: Colors.red[400],
                                              fontSize: 14,
                                              letterSpacing: -0.3,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  controller: scrollController,
                                  padding: const EdgeInsets.all(16),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            decoration: BoxDecoration(
                                              color: mutedForeground,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Create New Gathering',
                                          style: TextStyle(
                                            color: foreground,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Select Society',
                                            labelStyle: TextStyle(
                                              color: mutedForeground,
                                              fontSize: 14,
                                              letterSpacing: -0.3,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.group,
                                              color: mutedForeground,
                                              size: 20,
                                            ),
                                            filled: true,
                                            fillColor: muted,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: primaryColor,
                                                width: 1.5,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                    horizontal: 16),
                                          ),
                                          dropdownColor: cardBackground,
                                          value: _selectedSocietyId,
                                          items: _moderatedSocieties
                                              .map((society) {
                                            return DropdownMenuItem<String>(
                                              value: society['_id'],
                                              child: Text(
                                                society['name']!,
                                                style: TextStyle(
                                                  color: foreground,
                                                  fontSize: 14,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedSocietyId = value;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select a society';
                                            }
                                            return null;
                                          },
                                          menuMaxHeight: 200,
                                          style: TextStyle(
                                            color: foreground,
                                            fontSize: 14,
                                          ),
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: mutedForeground,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Title',
                                            labelStyle: TextStyle(
                                              color: mutedForeground,
                                              fontSize: 14,
                                              letterSpacing: -0.3,
                                            ),
                                            filled: true,
                                            fillColor: muted,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 1.5),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: foreground,
                                            fontSize: 14,
                                            letterSpacing: -0.3,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Please enter a title';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) =>
                                              _title = value!.trim(),
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Description',
                                            labelStyle: TextStyle(
                                              color: mutedForeground,
                                              fontSize: 14,
                                              letterSpacing: -0.3,
                                            ),
                                            filled: true,
                                            fillColor: muted,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                  color: primaryColor,
                                                  width: 1.5),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: foreground,
                                            fontSize: 14,
                                            letterSpacing: -0.3,
                                          ),
                                          maxLines: 3,
                                          onSaved: (value) => _description =
                                              value?.trim() ?? '',
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: muted,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: cardShadow,
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Gathering Radius: ${_radius.round()}m',
                                                style: TextStyle(
                                                  color: foreground,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                              Slider(
                                                value: _radius,
                                                min: 50,
                                                max: 500,
                                                divisions: 9,
                                                label: '${_radius.round()}m',
                                                activeColor: primaryColor,
                                                inactiveColor: mutedForeground,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _radius = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: muted,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: cardShadow,
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.event,
                                                color: primaryColor),
                                            title: Text(
                                              'Start Time',
                                              style: TextStyle(
                                                color: foreground,
                                                fontSize: 14,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            subtitle: Text(
                                              DateFormat(
                                                      'MMM dd, yyyy - hh:mm a')
                                                  .format(_startTime),
                                              style: TextStyle(
                                                color: mutedForeground,
                                                fontSize: 14,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            trailing: Icon(Icons.edit,
                                                color: primaryColor),
                                            onTap: () =>
                                                _selectDateTime(context, true),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: muted,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: cardShadow,
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            leading: Icon(Icons.event_available,
                                                color: primaryColor),
                                            title: Text(
                                              'End Time',
                                              style: TextStyle(
                                                color: foreground,
                                                fontSize: 14,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            subtitle: Text(
                                              DateFormat(
                                                      'MMM dd, yyyy - hh:mm a')
                                                  .format(_endTime),
                                              style: TextStyle(
                                                color: mutedForeground,
                                                fontSize: 14,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            trailing: Icon(Icons.edit,
                                                color: primaryColor),
                                            onTap: () =>
                                                _selectDateTime(context, false),
                                          ),
                                        ),
                                        if (_errorMessage != null)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            child: Text(
                                              _errorMessage!,
                                              style: TextStyle(
                                                color: Colors.red[400],
                                                fontSize: 14,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: background,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 2,
                                            ),
                                            onPressed:
                                                _isLoading ? null : _submitForm,
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Create Gathering',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: -0.3,
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
      final userLocation = LatLng(position.latitude, position.longitude);
      if (_userUniversity == 'Comsats' && _userCampus?.contains('Lahore') == true) {
        if (_isWithinBounds(userLocation)) {
          setState(() {
            _selectedLocation = userLocation;
          });
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: userLocation, zoom: _minZoomLevel),
            ),
          );
        } else {
          setState(() {
            _selectedLocation = _comsatsLahore;
            _errorMessage =
                // 'Your location is outside the allowed area; defaulting to Comsats Lahore';
                ' ';
          });
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _comsatsLahore, zoom: _minZoomLevel),
            ),
          );
        }
      } else if (_userUniversity == 'ITU' && _userCampus?.contains('Lahore') == true) {
        if (_isWithinBounds(userLocation)) {
          setState(() {
            _selectedLocation = userLocation;
          });
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: userLocation, zoom: _minZoomLevel),
            ),
          );
        } else {
          setState(() {
            _selectedLocation = _ituLahore;
            _errorMessage =
                // 'Your location is outside the allowed area; defaulting to ITU Lahore';
                ' ';
          });
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _ituLahore, zoom: _minZoomLevel),
            ),
          );
        }
      } else {
        setState(() {
          _selectedLocation = userLocation;
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: userLocation, zoom: _minZoomLevel),
          ),
        );
      }
    } catch (e) {
      setState(() {
        if (_userUniversity == 'Comsats' && _userCampus?.contains('Lahore') == true) {
          _selectedLocation = _comsatsLahore;
          _errorMessage =
              ' ';
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _comsatsLahore, zoom: _minZoomLevel),
            ),
          );
        } else if (_userUniversity == 'ITU' && _userCampus?.contains('Lahore') == true) {
          _selectedLocation = _ituLahore;
          _errorMessage =
              // 'Could not get current location; defaulting to ITU Lahore';
              ' ';
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _ituLahore, zoom: _minZoomLevel),
            ),
          );
        } else {
          _selectedLocation = const LatLng(0, 0);
          _errorMessage = 'Could not get current location';
        }
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final now = DateTime.now();
    final initialDate = isStartTime ? _startTime : _endTime;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              onPrimary: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
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
                primary: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                onPrimary: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                onSurface: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            child: child!,
        );
      });

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
            if (_endTime
                .isBefore(_startTime.add(const Duration(minutes: 30)))) {
              _endTime = _startTime.add(const Duration(minutes: 30));
            } else if (_endTime.difference(_startTime).inHours > 5) {
              _endTime = _startTime.add(const Duration(hours: 5));
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

      final now = DateTime.now();

      if (_startTime.isBefore(now)) {
        setState(() {
          _errorMessage = 'Start time cannot be in the past';
        });
        return;
      }

      if (_selectedLocation == null) {
        setState(() {
          _errorMessage = 'Please select a location on the map';
        });
        return;
      }

      if (!_isWithinBounds(_selectedLocation!)) {
        setState(() {
          _errorMessage = 'Selected location is outside the allowed area';
        });
        return;
      }

      if (_endTime.isBefore(_startTime.add(const Duration(minutes: 30)))) {
        setState(() {
          _errorMessage = 'Gathering must last at least 30 minutes';
        });
        return;
      }

      if (_endTime.difference(_startTime).inHours > 5) {
        setState(() {
          _errorMessage = 'Gathering cannot exceed 5 hours';
        });
        return;
      }

      if (_moderatedSocieties.isEmpty || _selectedSocietyId == null) {
        setState(() {
          _errorMessage = 'You must be a moderator to create a gathering';
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
          'societyId': _selectedSocietyId,
        };

        await _apiClient.post('/api/gatherings', data);

        if (!mounted) {
          return;
        }

        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Gathering created successfully')),
        );

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          navigator.pop();
        }
      } catch (e, stackTrace) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to create gathering. Please check your internet connection.';
            _isLoading = false;
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}