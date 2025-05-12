import 'dart:developer';

import 'package:beyondtheclass/core/utils/constants.dart';
import 'package:beyondtheclass/features/auth/providers/auth_provider.dart';
import 'package:beyondtheclass/pages/profile/settings/personalInfo/ProfileImageUploadPage.dart';
import 'package:beyondtheclass/shared/services/api_client.dart';
import 'package:beyondtheclass/shared/services/secure_storage_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PersonalInfoEditPage extends ConsumerStatefulWidget {
  const PersonalInfoEditPage({super.key});

  @override
  ConsumerState<PersonalInfoEditPage> createState() =>
      _PersonalInfoEditPageState();
}

class _PersonalInfoEditPageState extends ConsumerState<PersonalInfoEditPage> {
  bool isEditing = false;
  bool editPersonalEmail = false;
  bool _enableOtpField = false;
  bool _requireUniversityOtp = false;

  final apiClient = ApiClient();
  final nameController = TextEditingController();
  final universityEmailController = TextEditingController();
  final personalEmailController = TextEditingController();
  final secondaryEmailController = TextEditingController();
  final otpController = TextEditingController();
  final universityOtpController = TextEditingController();

  late String role;
  String signedInEmail = '';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    log("Auth Provider: $user");
    nameController.text = user?['name'];
    universityEmailController.text = user?['universityEmail'];
    personalEmailController.text = user?['personalEmail'];
    secondaryEmailController.text = user?['secondaryPersonalEmail'];
    signedInEmail = user?['email'];
    role = user?['role'];
  }

  Future<void> _pickMedia() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileImageUploadPage(),
        ),
      );

      if (result == true) {
        // Refresh profile data if image was updated successfully
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking media: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> updateName() async {
    try {
      await apiClient.put(
        '/api/user/update/name',
        {
          'name': nameController.text,
        },
      );
      setState(() {
        isEditing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Name updated successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating name: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> updatePersonalEmail() async {
    try {
      final response = await apiClient.put(
        '/api/user/update/personalEmail',
        {'personalEmail': personalEmailController.text},
      );
      if (response.isNotEmpty) {
        setState(() {
          _enableOtpField = true;
          _requireUniversityOtp = response['requireUniversityOtp'] == true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating personal email: $e'),
        ),
      );
    }
  }

  Future<void> verifyOtp() async {
    try {
      Map<String, String> payload = {
        'otp': otpController.text,
        'email': personalEmailController.text,
      };
      if (_requireUniversityOtp) {
        payload['universityEmailOtp'] = universityOtpController.text;
      }
      final response = await apiClient.post(
        '/api/user/verify/personalEmail/otp',
        payload,
      );
      if (response.isNotEmpty) {
        setState(() {
          _enableOtpField = false;
          _requireUniversityOtp = false;
          universityOtpController.clear();
          otpController.clear();
        });

        final userData = response['personalEmail'];
        final token = await SecureStorageService.instance.getToken();

        if (token != null) {
          final dataJSON = JwtDecoder.decode(token);
          // Update the specific field
          dataJSON['personalEmail'] = userData;

          final jwt = JWT(dataJSON);

          final convertedToJWT = jwt.sign(SecretKey(dotenv.get('JTM')));

          // Save the entire updated token
          await SecureStorageService.instance.saveToken(convertedToJWT);

          // Update Riverpod state using updateAuthState
          await ref
              .read(authProvider.notifier)
              .updateAuthState(dataJSON, convertedToJWT);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying OTP: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Personal Info'),
        backgroundColor: isDark ? colorScheme.surface : colorScheme.background,
        elevation: 0,
      ),
      body: Container(
        color: isDark ? colorScheme.surface : colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _pickMedia,
                      icon: Icon(Icons.camera_alt, color: colorScheme.primary),
                      label: Text(
                        'Change Profile Picture',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            colorScheme.primary.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Name Section
              Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? colorScheme.outline.withValues(alpha: 0.5)
                        : colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        readOnly: !isEditing,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (isEditing) {
                          updateName();
                        } else {
                          setState(() {
                            isEditing = true;
                          });
                        }
                      },
                      icon: Icon(
                        isEditing ? Icons.check : Icons.edit,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Name Section
              if (role != AppRoles.extOrg || role != AppRoles.noAccess) ...[
                Text(
                  'University Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outline.withValues(alpha: 0.5)
                          : colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: universityEmailController,
                          readOnly: true,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your university email',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (role == AppRoles.student || role == AppRoles.alumni) ...[
                Text(
                  'Personal Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outline.withValues(alpha: 0.5)
                          : colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: personalEmailController,
                          readOnly: !editPersonalEmail,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your personal email',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (editPersonalEmail) {
                            updatePersonalEmail();
                          } else {
                            setState(() {
                              editPersonalEmail = true;
                            });
                          }
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
                if (_enableOtpField) ...[
                  if (_requireUniversityOtp) ...[
                    Text('University Email OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? colorScheme.outline.withValues(alpha: 0.5)
                              : colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: universityOtpController,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Enter OTP sent to your university email',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('Personal Email OTP',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? colorScheme.outline.withValues(alpha: 0.5)
                            : colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: otpController,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter OTP sent to your personal email',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: verifyOtp,
                    child: const Text('Verify OTP(s)'),
                  ),
                ],
              ],

              if (role == AppRoles.alumni) ...[
                Text(
                  'Secondary Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outline.withValues(alpha: 0.5)
                          : colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: secondaryEmailController,
                          readOnly: true,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter your secondary email',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
