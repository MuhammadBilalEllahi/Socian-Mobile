import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


import 'package:image_cropper/image_cropper.dart';
class CreateSocietyPage extends ConsumerStatefulWidget {
  const CreateSocietyPage({super.key});

  @override
  ConsumerState<CreateSocietyPage> createState() => _CreateSocietyPageState();
}

class _CreateSocietyPageState extends ConsumerState<CreateSocietyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  // final _iconController = TextEditingController();
  File? _selectedIcon;
  CroppedFile? _selectedBanner;
  final _bannerController = TextEditingController();

List<String> _rolesList=[];
  String? _selectedSocietyType;
  String? _selectedCampus;
  String _selectedAllows = '';
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> _societyTypes = [];
  List<Map<String, dynamic>> _campuses = [];

  // shadcn/minimal palette for dark mode
  static const Color darkBg = Color(0xFF18181B);
  static const Color darkFg = Color(0xFFF4F4F5);
  static const Color darkMuted = Color(0xFF71717A);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkAccent = Color(0xFF6366F1);

  // shadcn-inspired palette for light mode
  static const Color lightBg = Color(0xFFF4F4F5);
  static const Color lightFg = Color(0xFF18181B);
  static const Color lightMuted = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightAccent = Color(0xFF4F46E5);

  // Helper to get theme colors based on brightness
  Map<String, Color> _getThemeColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return {
      'bg': isDark ? darkBg : lightBg,
      'fg': isDark ? darkFg : lightFg,
      'muted': isDark ? darkMuted : lightMuted,
      'border': isDark ? darkBorder : lightBorder,
      'accent': isDark ? darkAccent : lightAccent,
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchSocietyTypes();
    _fetchCampuses();
    // _rolesList = [
      // 'alumni', 'student', 'teacher', 'ext_org', 'all'
      // 'President',
      // 'Vice President',
      // 'Secretary',
      // 'Treasurer',
      // 'Member',
    // ];
    _rolesList.add(ref.read(authProvider).user?['role'] ?? 'unauthorized'); // Add the user's role
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  // Fetch society types (hypothetical endpoint)
  Future<void> _fetchSocietyTypes() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/api/society/types');
      log("_________________________________________________________Society Types: $response");
      setState(() {
        _societyTypes = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load society types';
      });
    }
  }

  // Fetch campuses (hypothetical endpoint or from auth)
  Future<void> _fetchCampuses() async {
    try {
      final authState = ref.read(authProvider);
      final userCampus = authState.user?['references']?['campus'];
      setState(() {
        _campuses = [
          {'_id': userCampus['_id'], 'name': userCampus['name']}
        ];
        _selectedCampus = userCampus['_id'];
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load campuses';
      });
    }
  }

  // Handle form submission
Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final apiClient = ApiClient();
    final authState = ref.read(authProvider);
    final userId = authState.user?['_id'];
    final role = authState.user?['role'];
    final universityId = authState.user?['references']?['university']?['_id'];

    // ✅ Safely flatten _selectedAllows into List<String>
    final List<String> flatAllows = [];

// NOTE: ROUTe IN BACKEND IS NOT UPDATED YET, WHEN UPDATED USER "apiClient.postFORMDATA"
        // Prepare multipart files
    // final iconFile = await MultipartFile.fromFile(
    //   _selectedIcon!.path,
    //   filename: 'icon.jpg',
    // );

    // MultipartFile? bannerFile;
    // if (_selectedBanner != null) {
    //   bannerFile = await MultipartFile.fromFile(
    //     _selectedBanner!.path,
    //     filename: 'banner.jpg',
    //   );
    // }

    // if (_selectedAllows is List) {
    //   for (var item in _selectedAllows) {
    //     if (item is String) {
    //       flatAllows.add(item);
    //     // ignore: unnecessary_type_check
    //     } 
        
    //     // else if (item is List && item is! String) {
    //     //   for (var innerItem in item) {
    //     //     flatAllows.add(innerItem.toString());
    //     //   }
    //     // } 
        
    //     else {
    //       flatAllows.add(item.toString());
    //     }
    //   }
    // } else if (_selectedAllows != null) {
    //   flatAllows.add(_selectedAllows.toString());
    // }

    debugPrint('Selected Allows (Raw): $_selectedAllows');
    debugPrint('Selected Allows (Flat): $flatAllows');

    final payload = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'societyTypeId': _selectedSocietyType,
      'category': 'default',
      // NOTE: ROUTe IN BACKEND IS NOT UPDATED YET, WHEN UPDATED USER "apiClient.postFORMDATA"
  //     'icon': iconFile,
  // 'banner': bannerFile,
      'allows': _selectedAllows,
      'president': userId,
    };

    debugPrint('Create Society Payload: ${jsonEncode(payload)}');

// NOTE: ROUTe IN BACKEND IS NOT UPDATED YET, WHEN UPDATED USER "apiClient.postFORMDATA"
    final response = await apiClient.post(
      '/api/society/create',
       payload,
    );

    if (response['message'] == 'Society created successfully') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Society created successfully')),
        );
        Navigator.of(context).pop();
      }
    }
  } catch (e) {
    setState(() {
      _error = e.toString().contains('Society already Exists')
          ? 'Society name already exists'
          : 'Failed to create society: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


Future<void> _mediaPicker(ImageSource source, {bool isBanner = false}) async {
  try {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    if (isBanner) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 1),
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Banner',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Banner',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() {
          _selectedBanner = croppedFile;
        });
      }
    } else {
      // For icon, we can crop as square
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Icon',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Icon',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() {
          _selectedIcon = File(croppedFile.path);
        });
      }
    }
  } catch (e) {
    log('Error in image picker/cropper: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process image: ${e.toString()}')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final padding = isTablet ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: colors['bg'],
      appBar: AppBar(
        backgroundColor: colors['bg'],
        elevation: 0,
        iconTheme: IconThemeData(color: colors['fg']),
        title: Text(
          'Create Society',
          style: TextStyle(
            color: colors['fg'],
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: colors['fg']),
                  decoration: InputDecoration(
                    labelText: 'Society Name',
                    labelStyle: TextStyle(color: colors['muted']),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['border']!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['accent']!),
                    ),
                  ),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: colors['fg']),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: colors['muted']),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['border']!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['accent']!),
                    ),
                  ),
                  validator: (value) =>
                      value!.trim().isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                // Society Type
                DropdownButtonFormField<String>(
                  value: _selectedSocietyType,
                  decoration: InputDecoration(
                    labelText: 'Society Type',
                    labelStyle: TextStyle(color: colors['muted']),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['border']!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['accent']!),
                    ),
                  ),
                  style: TextStyle(color: colors['fg']),
                  items: _societyTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['_id'],
                      child: Text(type['societyType']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _selectedSocietyType = value;
                  }),
                  validator: (value) =>
                      value == null ? 'Society type is required' : null,
                ),
                const SizedBox(height: 16),
                // Campus
                DropdownButtonFormField<String>(
                  value: _selectedCampus,
                  decoration: InputDecoration(
                    labelText: 'Campus',
                    labelStyle: TextStyle(color: colors['muted']),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['border']!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colors['accent']!),
                    ),
                  ),
                  style: TextStyle(color: colors['fg']),
                  items: _campuses.map((campus) {
                    return DropdownMenuItem<String>(
                      value: campus['_id'],
                      child: Text(campus['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _selectedCampus = value;
                  }),
                  validator: (value) =>
                      value == null ? 'Campus is required' : null,
                ),
                const SizedBox(height: 16),
                // Allows
                Text(
                  'Allowed Roles',
                  style: TextStyle(
                    color: colors['fg'],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _rolesList
                      .map((role) => ChoiceChip(
                            label: Text(role),
                            selected: _selectedAllows == role,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAllows=role;
                                } else {
                                  _selectedAllows='';
                                }
                              });
                            },
                            selectedColor: colors['accent']!.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: _selectedAllows ==role
                                  ? colors['accent']
                                  : colors['fg'],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Icon URL
                GestureDetector(
                  onTap:()=>_mediaPicker(ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors['bg'],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors['border']!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.image, color: colors['fg']),
                        const SizedBox(width: 8),
                        Text(
                          'Upload Icon (optional)',
                          style: TextStyle(color: colors['fg']),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectedIcon =null,
                  child: _selectedIcon != null
                      ? Image.file(
                          _selectedIcon!,
                          width: 100,
                          height: 100,
                        )
                      : const SizedBox.shrink(),
                ),

                GestureDetector(
                  onTap: () => _mediaPicker(ImageSource.gallery, isBanner: true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors['bg'],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors['border']!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: colors['fg']),
                        const SizedBox(width: 8),
                        Text(
                          'Banner Image (optional)',
                          style: TextStyle(color: colors['fg']),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectedBanner =null,
                  child: _selectedBanner != null
                      ? Image.file(
                          File(_selectedBanner!.path),
                          width: 100,
                          height: 100,
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                // Error message
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['accent'],
                      foregroundColor: colors['fg'],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: colors['fg'])
                        : Text(
                            'Create Society',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}