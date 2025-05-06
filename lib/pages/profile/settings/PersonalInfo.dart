// import 'dart:io';
// import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
// import 'package:beyondtheclass/shared/services/api_client.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';

// class PersonalInfo extends ConsumerStatefulWidget {
//   const PersonalInfo({super.key});

//   @override
//   ConsumerState<PersonalInfo> createState() => _PersonalInfoState();
// }

// class _PersonalInfoState extends ConsumerState<PersonalInfo> {
//   final _formKey = GlobalKey<FormState>();
//   final _apiClient = ApiClient();
//   late TextEditingController _nameController;
//   late TextEditingController _usernameController;
//   XFile? _pickedImage;
//   String? _currentPictureUrl;
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController();
//     _usernameController = TextEditingController();
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final auth = ref.read(authProvider);
//       final userId = auth.user?['_id'];
//       if (userId == null) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'User not logged in';
//         });
//         return;
//       }

//       final response = await _apiClient.get('/api/user/profile', queryParameters: {'id': userId});
//       if (response.containsKey('error') || response['profile'] == null) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = response['error'] ?? 'User not found';
//         });
//         return;
//       }

//       final userData = response['profile'] as Map<String, dynamic>;
//       setState(() {
//         _nameController.text = userData['name'] ?? '';
//         _usernameController.text = userData['username'] ?? '';
//         _currentPictureUrl = userData['profile']?['picture'];
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Failed to load user data: $e';
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = pickedFile;
//       });
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final auth = ref.read(authProvider);
//       final userId = auth.user?['_id'];
//       if (userId == null) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'User not logged in';
//         });
//         return;
//       }

//       final formData = {
//         'name': _nameController.text,
//         'username': _usernameController.text,
//       };

//       // Handle image upload if picked
//       if (_pickedImage != null) {
//         final file = File(_pickedImage!.path);
//         final response = await _apiClient.uploadFile(
//           '/api/user/update',
//           file,
//           'picture',
//           additionalFields: formData,
//         );
//         if (response.containsKey('error')) {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = response['error'];
//           });
//           return;
//         }
//       } else {
//         // Update without image
//         final response = await _apiClient.patch('/api/user/update', formData);
//         if (response.containsKey('error')) {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = response['error'];
//           });
//           return;
//         }
//       }

//       // Refresh user data
//       await _fetchUserData();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Failed to update profile: $e';
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _usernameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
//     final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
//     final mutedForeground = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
//     final border = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
//     final accent = isDarkMode ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
//     const primary = Color(0xFF8B5CF6);

//     if (_isLoading) {
//       return Scaffold(
//         backgroundColor: background,
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_errorMessage != null) {
//       return Scaffold(
//         backgroundColor: background,
//         body: Center(
//           child: Text(
//             _errorMessage!,
//             style: TextStyle(color: mutedForeground),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         backgroundColor: background,
//         elevation: 0,
//         title: Text(
//           'Edit Personal Info',
//           style: TextStyle(color: foreground),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: foreground),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // Profile Picture
//               Center(
//                 child: GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: primary, width: 2),
//                     ),
//                     child: CircleAvatar(
//                       radius: 50,
//                       backgroundColor: accent,
//                       backgroundImage: _pickedImage != null
//                           ? FileImage(File(_pickedImage!.path))
//                           : _currentPictureUrl != null
//                               ? NetworkImage(_currentPictureUrl!)
//                               : const AssetImage("assets/images/profilepic2.jpg") as ImageProvider,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Center(
//                 child: Text(
//                   'Tap to change picture',
//                   style: TextStyle(color: mutedForeground, fontSize: 12),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Name Field
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   labelStyle: TextStyle(color: mutedForeground),
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: border),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: primary),
//                   ),
//                 ),
//                 style: TextStyle(color: foreground),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Username Field
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   labelStyle: TextStyle(color: mutedForeground),
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: border),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: primary),
//                   ),
//                 ),
//                 style: TextStyle(color: foreground),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter a username';
//                   }
//                   if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
//                     return 'Username can only contain letters, numbers, underscores, or hyphens';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Save Button
//               ElevatedButton(
//                 onPressed: _saveChanges,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primary,
//                   foregroundColor: foreground,
//                   minimumSize: const Size(double.infinity, 48),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Save Changes'),
//               ),
//               const SizedBox(height: 16),

//               // Cancel Button
//               OutlinedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: mutedForeground,
//                   side: BorderSide(color: border),
//                   minimumSize: const Size(double.infinity, 48),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }