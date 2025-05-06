import 'dart:io';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileImageUploadPage extends ConsumerStatefulWidget {
  const ProfileImageUploadPage({super.key});

  @override
  ConsumerState<ProfileImageUploadPage> createState() =>
      _ProfileImageUploadPageState();
}

class _ProfileImageUploadPageState
    extends ConsumerState<ProfileImageUploadPage> {
  File? _selectedImage;
  bool _isUploading = false;
  final _apiClient = ApiClient();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      developer.log('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final data = <String, dynamic>{'file': ''};
      data['file'] = await MultipartFile.fromFile(
        _selectedImage!.path,
        filename:
            '${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.path.split('/').last}',
        contentType: MediaType.parse('image/jpeg'),
      );

      final response = await _apiClient.putFormData(
        ApiConstants.uploadProfilePic,
        data,
      );

      developer.log("Profile pic response $response");

      final userData = response['picture'];
      final token = await SecureStorageService.instance.getToken();

      if (token != null) {
        final dataJSON = JwtDecoder.decode(token);
        // Update the specific field
        dataJSON['profile']['picture'] = userData;

        final jwt = JWT(dataJSON);
        final convertedToJWT = jwt.sign(SecretKey(dotenv.get('JTM')));

        // Save the entire updated token
        await SecureStorageService.instance.saveToken(convertedToJWT);

        // Update Riverpod state using updateAuthState
        await ref
            .read(authProvider.notifier)
            .updateAuthState(dataJSON, convertedToJWT);

        developer.log("serviceAuthToken $dataJSON");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
        Navigator.pop(
            context, true); // Return true to indicate successful update
      }
    } catch (e) {
      developer.log('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = isDarkMode ? const Color(0xFF09090B) : Colors.white;
    final foreground = isDarkMode ? Colors.white : const Color(0xFF09090B);
    const primary = Color.fromARGB(255, 124, 124, 124);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Text(
          'Update Profile Picture',
          style: TextStyle(color: foreground),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: foreground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  _selectedImage == null || _isUploading ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Update Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
