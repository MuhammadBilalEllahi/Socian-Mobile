import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socian/shared/services/api_client.dart';

class SocietyVerification extends StatefulWidget {
  final String? societyId;
  final String? societyName;

  const SocietyVerification({
    super.key,
    this.societyId,
    this.societyName,
  });

  @override
  State<SocietyVerification> createState() => _SocietyVerificationState();
}

class _SocietyVerificationState extends State<SocietyVerification> {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();

  // Form Controllers
  final _societyController = TextEditingController();
  final _advisorEmailController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _commentsController = TextEditingController();

  // Form State
  String? _selectedSocietyId;
  String? _selectedModerator;
  bool _isSubmitting = false;
  bool _communityVoting = false;

  // File Upload State
  File? _registrationCertificate;
  File? _eventPicture;
  File? _advisorEmailScreenshot;

  // Society and Moderator Lists
  List<Map<String, dynamic>> _societies = [];
  List<Map<String, dynamic>> _moderators = [];
  bool _isLoadingData = true;

  // Verification Requirements
  final Map<String, bool> _requirements = {
    'registrationCertificate': false,
    'eventPicture': false,
    'advisorEmailScreenshot': false,
    'advisorEmail': false,
    'adminEmail': false,
    'moderatorRequest': false,
    'communityVoting': false,
  };

  // Theme Colors
  static const Color darkBg = Color(0xFF000000);
  static const Color darkFg = Color(0xFFFFFFFF);
  static const Color darkMuted = Color(0xFF888888);
  static const Color darkBorder = Color(0xFF222222);
  static const Color darkAccent = Color(0xFFFFFFFF);

  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightFg = Color(0xFF000000);
  static const Color lightMuted = Color(0xFF888888);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightAccent = Color(0xFF000000);

  Map<String, Color> get _colors {
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
    if (widget.societyName != null) {
      _societyController.text = widget.societyName!;
      _selectedSocietyId = widget.societyId;
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _societyController.dispose();
    _advisorEmailController.dispose();
    _adminEmailController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final [societiesResponse, moderatorsResponse] = await Future.wait([
        _apiClient.get('/api/society/all'),
        _apiClient.get('/api/user/campus-moderators'),
      ]);

      if (mounted) {
        setState(() {
          _societies = List<Map<String, dynamic>>.from(
              societiesResponse['societies'] ?? []);
          _moderators = List<Map<String, dynamic>>.from(
              moderatorsResponse['moderators'] ?? []);
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        _showErrorSnackBar('Failed to load data: ${e.toString()}');
      }
    }
  }

  Future<void> _pickFile(String type) async {
    try {
      if (type == 'eventPicture') {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _eventPicture = File(image.path);
            _requirements['eventPicture'] = true;
          });
        }
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          setState(() {
            switch (type) {
              case 'registrationCertificate':
                _registrationCertificate = file;
                _requirements['registrationCertificate'] = true;
                break;
              case 'advisorEmailScreenshot':
                _advisorEmailScreenshot = file;
                _requirements['advisorEmailScreenshot'] = true;
                break;
            }
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: ${e.toString()}');
    }
  }

  void _updateRequirement(String key, bool value) {
    setState(() {
      _requirements[key] = value;
    });
  }

  bool get _isFormValid {
    return _requirements.values.any((req) => req) && _selectedSocietyId != null;
  }

  Future<void> _submitVerificationRequest() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      _showErrorSnackBar('Please complete the required fields');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create FormData for file uploads
      final formData = <String, dynamic>{
        'societyId': _selectedSocietyId,
        'advisorEmail': _advisorEmailController.text.trim(),
        'adminEmail': _adminEmailController.text.trim(),
        'moderatorId': _selectedModerator,
        'communityVoting': _communityVoting,
        'comments': _commentsController.text.trim(),
        'requirements': _requirements,
      };

      // In a real implementation, you would upload files separately
      // For now, we'll just send the form data
      await _apiClient.post('/api/society/verification-request', formData);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorSnackBar(
          'Failed to submit verification request: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _colors['bg'],
        surfaceTintColor: _colors['bg'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _colors['border']!, width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              'Request Submitted',
              style: TextStyle(
                color: _colors['fg'],
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Your society verification request has been submitted successfully. You will be notified about the status updates.',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to society page
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: _colors['accent'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors['bg'],
      appBar: AppBar(
        backgroundColor: _colors['bg'],
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: _colors['fg']),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Society Verification Request',
              style: TextStyle(
                color: _colors['fg'],
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingData
          ? Center(
              child: CircularProgressIndicator(
                color: _colors['accent'],
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 24),
                    _buildSocietySelectionCard(),
                    const SizedBox(height: 24),
                    _buildVerificationRequirementsCard(),
                    const SizedBox(height: 24),
                    _buildContactInformationCard(),
                    const SizedBox(height: 24),
                    _buildAdditionalOptionsCard(),
                    if (_communityVoting) ...[
                      const SizedBox(height: 24),
                      _buildPollPreviewCard(),
                    ],
                    const SizedBox(height: 24),
                    _buildCommentsCard(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _colors['bg'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _colors['border']!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _colors['accent']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified,
                  color: _colors['accent'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify Your Society',
                      style: TextStyle(
                        color: _colors['fg'],
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get verified with the university community',
                      style: TextStyle(
                        color: _colors['muted'],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Submit the required documents and information to verify your society. This process helps ensure authenticity and builds trust within the university community.',
            style: TextStyle(
              color: _colors['muted'],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocietySelectionCard() {
    return _buildCard(
      title: 'Society Information',
      icon: Icons.groups,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedSocietyId,
          decoration: InputDecoration(
            labelText: 'Select Society Name',
            labelStyle: TextStyle(color: _colors['muted']),
            filled: true,
            fillColor: _colors['bg'],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _colors['border']!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _colors['accent']!, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          dropdownColor: _colors['bg'],
          style: TextStyle(color: _colors['fg']),
          items: _societies.map((society) {
            return DropdownMenuItem<String>(
              value: society['_id'],
              child: Text(
                society['name'] ?? 'Unknown',
                style: TextStyle(color: _colors['fg']),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSocietyId = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a society';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVerificationRequirementsCard() {
    return _buildCard(
      title: 'Verification Requirements',
      icon: Icons.checklist,
      children: [
        Text(
          'Please provide at least one of the following requirements:',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        _buildFileUploadTile(
          'Registration Certificate',
          'Upload official society registration document',
          'registrationCertificate',
          _registrationCertificate,
          Icons.description,
        ),
        _buildFileUploadTile(
          'Recent Event Picture',
          'Upload picture with university logo',
          'eventPicture',
          _eventPicture,
          Icons.photo_camera,
        ),
        _buildFileUploadTile(
          'Advisor Email Screenshot',
          'Upload screenshot of advisor email',
          'advisorEmailScreenshot',
          _advisorEmailScreenshot,
          Icons.email,
        ),
      ],
    );
  }

  Widget _buildFileUploadTile(
    String title,
    String subtitle,
    String key,
    File? file,
    IconData icon,
  ) {
    final isUploaded = file != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _colors['bg'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isUploaded ? Colors.green.withOpacity(0.3) : _colors['border']!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUploaded
                ? Colors.green.withOpacity(0.1)
                : _colors['accent']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isUploaded ? Icons.check_circle : icon,
            color: isUploaded ? Colors.green : _colors['accent'],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: _colors['fg'],
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: _colors['muted'],
                fontSize: 13,
              ),
            ),
            if (isUploaded) ...[
              const SizedBox(height: 4),
              Text(
                file.path.split('/').last,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: isUploaded
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.visibility,
                        color: _colors['accent'], size: 20),
                    onPressed: () {
                      // Preview file functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () {
                      setState(() {
                        switch (key) {
                          case 'registrationCertificate':
                            _registrationCertificate = null;
                            break;
                          case 'eventPicture':
                            _eventPicture = null;
                            break;
                          case 'advisorEmailScreenshot':
                            _advisorEmailScreenshot = null;
                            break;
                        }
                        _requirements[key] = false;
                      });
                    },
                  ),
                ],
              )
            : IconButton(
                icon: Icon(Icons.upload_file, color: _colors['accent']),
                onPressed: () => _pickFile(key),
              ),
        onTap: isUploaded ? null : () => _pickFile(key),
      ),
    );
  }

  Widget _buildContactInformationCard() {
    return _buildCard(
      title: 'Contact Information',
      icon: Icons.contact_mail,
      children: [
        TextFormField(
          controller: _advisorEmailController,
          style: TextStyle(color: _colors['fg']),
          decoration: _buildInputDecoration('Faculty Advisor Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            _updateRequirement('advisorEmail', value.trim().isNotEmpty);
          },
          validator: (value) {
            if (value?.trim().isNotEmpty == true) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _adminEmailController,
          style: TextStyle(color: _colors['fg']),
          decoration: _buildInputDecoration('University Admin Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            _updateRequirement('adminEmail', value.trim().isNotEmpty);
          },
          validator: (value) {
            if (value?.trim().isNotEmpty == true) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedModerator,
          decoration: _buildInputDecoration('Campus Moderator (Optional)'),
          dropdownColor: _colors['bg'],
          style: TextStyle(color: _colors['fg']),
          items: _moderators.map((moderator) {
            return DropdownMenuItem<String>(
              value: moderator['_id'],
              child: Text(
                moderator['name'] ?? 'Unknown',
                style: TextStyle(color: _colors['fg']),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedModerator = value;
              _updateRequirement('moderatorRequest', value != null);
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalOptionsCard() {
    return _buildCard(
      title: 'Additional Options',
      icon: Icons.settings,
      children: [
        CheckboxListTile(
          value: _communityVoting,
          onChanged: (value) {
            setState(() {
              _communityVoting = value ?? false;
              _updateRequirement('communityVoting', _communityVoting);
            });
          },
          title: Text(
            'Community Voting Poll',
            style: TextStyle(
              color: _colors['fg'],
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Allow community members to vote on your verification',
            style: TextStyle(
              color: _colors['muted'],
              fontSize: 13,
            ),
          ),
          activeColor: _colors['accent'],
          checkColor: _colors['bg'],
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPollPreviewCard() {
    return _buildCard(
      title: 'Poll Preview',
      icon: Icons.poll,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _colors['accent']!.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _colors['border']!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Should "${widget.societyName ?? "Sample Society"}" be verified?',
                style: TextStyle(
                  color: _colors['fg'],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildPollOption('Yes, verify this society', 0.7, Colors.green),
              const SizedBox(height: 8),
              _buildPollOption('No, needs more evidence', 0.2, Colors.red),
              const SizedBox(height: 8),
              _buildPollOption('Abstain', 0.1, _colors['muted']!),
              const SizedBox(height: 12),
              Text(
                '127 votes • 3 days remaining',
                style: TextStyle(
                  color: _colors['muted'],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPollOption(String text, double percentage, Color color) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _colors['bg'],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _colors['border']!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: _colors['fg'],
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsCard() {
    return _buildCard(
      title: 'Additional Comments',
      icon: Icons.comment,
      children: [
        TextFormField(
          controller: _commentsController,
          style: TextStyle(color: _colors['fg']),
          decoration: _buildInputDecoration(
            'Provide any additional information or context',
          ),
          maxLines: 4,
          maxLength: 500,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            return Text(
              '$currentLength/${maxLength ?? 0}',
              style: TextStyle(
                color: _colors['muted'],
                fontSize: 12,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed:
            _isSubmitting || !_isFormValid ? null : _submitVerificationRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: _colors['accent'],
          foregroundColor: _colors['bg'],
          disabledBackgroundColor: _colors['muted']!.withOpacity(0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: _colors['bg'],
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: TextStyle(
                      color: _colors['bg'],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Submit Verification Request',
                style: TextStyle(
                  color: _colors['bg'],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _colors['bg'],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _colors['border']!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _colors['accent'], size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: _colors['fg'],
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _colors['muted']),
      filled: true,
      fillColor: _colors['bg'],
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _colors['border']!),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _colors['accent']!, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
