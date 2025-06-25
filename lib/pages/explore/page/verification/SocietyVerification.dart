import 'dart:convert';
import 'dart:developer';
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
  final List<File> _customDocuments = [];
  final List<String> _customDocumentNames = [];

  // Society and Moderator Lists
  List<Map<String, dynamic>> _moderators = [];
  bool _isLoadingData = true;

  // Verification Status
  bool _hasExistingRequest = false;
  Map<String, dynamic>? _existingRequest;
  bool _societyAlreadyVerified = false;
  bool _isUpdateMode = false;
  bool _canSubmitNew = true;

  // Verification Requirements
  final Map<String, bool> _requirements = {
    'registrationCertificate': false,
    'eventPicture': false,
    'advisorEmailScreenshot': false,
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
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load moderators and verification status in parallel
      log('Loading initial data ${widget.societyId}');
      final futures = await Future.wait([
        _apiClient.get('/api/user/campus-moderators'),
        widget.societyId != null
            ? _apiClient
                .get('/api/society/verification-status/${widget.societyId}')
            : Future.value(null),
      ]);

      final moderatorsResponse = futures[0] as Map<String, dynamic>;
      final verificationStatusResponse = futures[1] as Map<String, dynamic>?;

      if (mounted) {
        setState(() {
          _moderators = List<Map<String, dynamic>>.from(
              moderatorsResponse['moderators'] ?? []);

          // Handle verification status
          if (verificationStatusResponse != null) {
            _hasExistingRequest =
                verificationStatusResponse['hasRequest'] ?? false;
            _societyAlreadyVerified =
                verificationStatusResponse['societyVerified'] ?? false;
            _canSubmitNew = verificationStatusResponse['canSubmitNew'] ?? true;
            _existingRequest = verificationStatusResponse['request'];

            // If there's an existing request, populate the form with its data
            if (_hasExistingRequest && _existingRequest != null) {
              final status = _existingRequest!['status'] as String;

              // Allow updates only for pending and under_review requests
              _isUpdateMode = (status == 'pending' || status == 'under_review');

              // If request is rejected, allow new submission (don't populate form)
              if (status != 'rejected') {
                _selectedModerator =
                    _existingRequest!['assignedCampusModerator']?['_id'];
                _communityVoting =
                    _existingRequest!['communityVoting'] ?? false;
                _commentsController.text = _existingRequest!['comments'] ?? '';

                // Update requirements from existing request
                final existingRequirements =
                    _existingRequest!['requirements'] as Map<String, dynamic>?;
                if (existingRequirements != null) {
                  existingRequirements.forEach((key, value) {
                    if (_requirements.containsKey(key)) {
                      _requirements[key] = value ?? false;
                    }
                  });
                }
              }
            }
          }

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

  Future<void> _pickFile(String type, {int? customIndex}) async {
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
      } else if (type == 'customDocument') {
        if (_customDocuments.length >= 5) {
          _showErrorSnackBar('Maximum 5 custom documents allowed');
          return;
        }

        // Show dialog to enter document name first
        final documentName = await _showDocumentNameDialog();
        if (documentName == null || documentName.trim().isEmpty) return;

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          setState(() {
            if (customIndex != null && customIndex < _customDocuments.length) {
              // Replace existing document
              _customDocuments[customIndex] = file;
              _customDocumentNames[customIndex] = documentName.trim();
            } else {
              // Add new document
              _customDocuments.add(file);
              _customDocumentNames.add(documentName.trim());
            }
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

  Future<String?> _showDocumentNameDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _colors['bg'],
        surfaceTintColor: _colors['bg'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _colors['border']!, width: 1),
        ),
        title: Text(
          'Document Name',
          style: TextStyle(
            color: _colors['fg'],
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: _colors['fg']),
          decoration: _buildInputDecoration('Enter document name'),
          autofocus: true,
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: _colors['muted']),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a document name'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            child: Text(
              'Add',
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

  void _updateRequirement(String key, bool value) {
    setState(() {
      _requirements[key] = value;
    });
  }

  bool get _isFormValid {
    // If society is already verified, disable form
    if (_societyAlreadyVerified) return false;

    // If there's an existing request but cannot submit new, disable form
    if (_hasExistingRequest &&
        _existingRequest != null &&
        !_canSubmitNew &&
        !_isUpdateMode) {
      return false;
    }

    // In update mode, allow updates with new content
    if (_isUpdateMode) {
      final hasNewCustomDocuments = _customDocuments.isNotEmpty;
      final hasNewRequirements = _hasNewRequirements();
      final hasNewComments = _hasNewComments();
      return hasNewCustomDocuments || hasNewRequirements || hasNewComments;
    }

    // For new requests (including after rejection)
    final hasBasicRequirements = _requirements.values.any((req) => req);
    final hasCustomDocuments = _customDocuments.isNotEmpty;
    return (hasBasicRequirements || hasCustomDocuments) &&
        _selectedSocietyId != null;
  }

  bool _hasNewRequirements() {
    if (_existingRequest == null) return false;

    final existingRequirements =
        _existingRequest!['requirements'] as Map<String, dynamic>?;
    if (existingRequirements == null) return true;

    // Check if any requirement is being set from false to true
    return _requirements.entries.any((entry) {
      final current = entry.value;
      final existing = existingRequirements[entry.key] ?? false;
      return current && !existing; // New requirement being added
    });
  }

  bool _hasNewComments() {
    if (_existingRequest == null) return true;

    final existingComments = _existingRequest!['comments'] as String? ?? '';
    final currentComments = _commentsController.text.trim();

    // Allow if comments are longer (expanding) or if no existing comments
    return currentComments.isNotEmpty &&
        (existingComments.isEmpty ||
            currentComments.length > existingComments.length);
  }

  String _getSubmitButtonText() {
    if (_societyAlreadyVerified) {
      return 'Society Already Verified';
    }

    if (_isUpdateMode) {
      return 'Update Verification Request';
    }

    if (_hasExistingRequest && _existingRequest != null) {
      final status = _existingRequest!['status'] as String;
      switch (status) {
        case 'pending':
          return 'Request Already Submitted';
        case 'under_review':
          return 'Request Under Review';
        case 'rejected':
          return 'Submit New Verification Request';
        case 'approved':
          return 'Request Already Approved';
        default:
          return 'Submit Verification Request';
      }
    }

    return 'Submit Verification Request';
  }

  Future<void> _submitVerificationRequest() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please correct the form errors');
      return;
    }

    if (!_isFormValid) {
      if (_isUpdateMode) {
        _showErrorSnackBar(
            'Please add new documents, requirements, or expand comments to strengthen your request');
      } else {
        _showErrorSnackBar(
            'Please upload at least one verification document or custom document');
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isUpdateMode) {
        // Update existing request
        await _updateVerificationRequest();
      } else {
        // Create new request (including after rejection)
        await _createVerificationRequest();
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      final actionType = _isUpdateMode
          ? "update"
          : (_hasExistingRequest && _existingRequest?['status'] == 'rejected')
              ? "resubmit"
              : "submit";
      _showErrorSnackBar(
          'Failed to $actionType verification request: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _createVerificationRequest() async {
    final formData = <String, dynamic>{
      'societyId': _selectedSocietyId,
      'moderatorId': _selectedModerator,
      'communityVoting': _communityVoting.toString(),
      'comments': _commentsController.text.trim(),
      'requirements': jsonEncode(_requirements),
      'customDocumentNames': jsonEncode(_customDocumentNames),
    };

    // Add files to form data if they exist
    if (_registrationCertificate != null) {
      formData['registrationCertificate'] = _registrationCertificate;
    }

    if (_eventPicture != null) {
      formData['eventPicture'] = _eventPicture;
    }

    if (_advisorEmailScreenshot != null) {
      formData['advisorEmailScreenshot'] = _advisorEmailScreenshot;
    }

    if (_customDocuments.isNotEmpty) {
      formData['customDocuments'] = _customDocuments;
    }

    await _apiClient.postFormData(
        '/api/society/verification-request', formData);
  }

  Future<void> _updateVerificationRequest() async {
    if (_existingRequest == null) return;

    final requestId = _existingRequest!['id'];
    final formData = <String, dynamic>{
      'communityVoting': _communityVoting.toString(),
      'comments': _commentsController.text.trim(),
      'requirements': jsonEncode(_requirements),
      'customDocumentNames': jsonEncode(_customDocumentNames),
    };

    // Add new files for strengthening the request
    if (_registrationCertificate != null) {
      formData['registrationCertificate'] = _registrationCertificate;
    }

    if (_eventPicture != null) {
      formData['eventPicture'] = _eventPicture;
    }

    if (_advisorEmailScreenshot != null) {
      formData['advisorEmailScreenshot'] = _advisorEmailScreenshot;
    }

    if (_customDocuments.isNotEmpty) {
      formData['customDocuments'] = _customDocuments;
    }

    await _apiClient.putFormData(
        '/api/society/verification-request/$requestId', formData);
  }

  void _showSuccessDialog() {
    final isUpdate = _isUpdateMode;
    final isResubmission = _hasExistingRequest &&
        _existingRequest?['status'] == 'rejected' &&
        !isUpdate;

    String title;
    String message;

    if (isUpdate) {
      title = 'Request Updated';
      message =
          'Your society verification request has been updated successfully with additional information. This strengthens your verification case.';
    } else if (isResubmission) {
      title = 'Request Resubmitted';
      message =
          'Your new verification request has been submitted successfully. We hope you have addressed the previous feedback. You will be notified about the status updates.';
    } else {
      title = 'Request Submitted';
      message =
          'Your society verification request has been submitted successfully. You will be notified about the status updates.';
    }

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
              title,
              style: TextStyle(
                color: _colors['fg'],
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          message,
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 24),
                    // Show existing request status if applicable
                    if (_societyAlreadyVerified) _buildVerifiedStatusCard(),
                    if (_hasExistingRequest && !_societyAlreadyVerified)
                      _buildExistingRequestCard(),
                    if (_hasExistingRequest || _societyAlreadyVerified)
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
                      _isUpdateMode
                          ? 'Strengthen Your Verification'
                          : 'Verify Your Society',
                      style: TextStyle(
                        color: _colors['fg'],
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isUpdateMode
                          ? 'Add more evidence to strengthen your request'
                          : 'Get verified with the university community',
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
            _isUpdateMode
                ? 'Add more evidence to strengthen your request'
                : (_hasExistingRequest &&
                        _existingRequest?['status'] == 'rejected' &&
                        _canSubmitNew)
                    ? 'Your previous request was rejected. Please review the feedback and submit a new request with improved documentation.'
                    : 'Submit the required documents and information to verify your society. This process helps ensure authenticity and builds trust within the university community.',
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

  Widget _buildVerifiedStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
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
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Society Already Verified',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This society has already been verified',
                      style: TextStyle(
                        color: Colors.green[600],
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
            'Congratulations! This society has already been verified by the administrators. No further action is required.',
            style: TextStyle(
              color: Colors.green[600],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingRequestCard() {
    if (_existingRequest == null) return const SizedBox.shrink();

    final status = _existingRequest!['status'] as String;
    final processingTime = _existingRequest!['processingTime'] as String? ?? '';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.yellow;
        statusIcon = Icons.pending;
        statusText = 'Pending Review';
        break;
      case 'under_review':
        statusColor = Colors.blue;
        statusIcon = Icons.rate_review;
        statusText = 'Under Review';
        break;
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown Status';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
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
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Request Status',
                      style: TextStyle(
                        color: statusColor == Colors.yellow
                            ? Colors.orange[700]
                            : statusColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor == Colors.yellow
                            ? Colors.orange[600]
                            : statusColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule,
                  color: statusColor == Colors.yellow
                      ? Colors.orange[600]
                      : statusColor,
                  size: 16),
              const SizedBox(width: 8),
              Text(
                'Processing time: $processingTime',
                style: TextStyle(
                  color: statusColor == Colors.yellow
                      ? Colors.orange[600]
                      : statusColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (_existingRequest!['adminReview'] != null &&
              _existingRequest!['adminReview']['reviewNotes'] != null) ...[
            const SizedBox(height: 12),
            Text(
              'Admin Review:',
              style: TextStyle(
                color: statusColor == Colors.yellow
                    ? Colors.orange[700]
                    : statusColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _existingRequest!['adminReview']['reviewNotes'],
              style: TextStyle(
                color: statusColor == Colors.yellow
                    ? Colors.orange[600]
                    : statusColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          if (status == 'rejected' &&
              _existingRequest!['adminReview'] != null &&
              _existingRequest!['adminReview']['rejectionReason'] != null) ...[
            const SizedBox(height: 12),
            Text(
              'Rejection Reason:',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _existingRequest!['adminReview']['rejectionReason'],
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          if (_isUpdateMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can strengthen this request by adding more documents, requirements, or expanding your comments below.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (status == 'rejected' && _canSubmitNew) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.refresh, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can submit a new verification request below. Address the rejection feedback to improve your chances.',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationRequirementsCard() {
    final hasVerificationDocs = _requirements.values.any((req) => req);
    final hasCustomDocs = _customDocuments.isNotEmpty;

    return _buildCard(
      title: 'Verification Requirements',
      icon: Icons.checklist,
      children: [
        Text(
          _isUpdateMode
              ? 'Add more documents and requirements to strengthen your verification request:'
              : 'You can either provide verification documents below OR upload custom documents in the section below:',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (_isUpdateMode) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Note: Already submitted documents cannot be changed, but you can add new ones.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
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
        const SizedBox(height: 24),
        _buildCustomDocumentsSection(),
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
                    onPressed: () => _showDocumentPreview(file, title),
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

  Widget _buildCustomDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_open, color: _colors['accent'], size: 20),
            const SizedBox(width: 8),
            Text(
              'Additional Documents',
              style: TextStyle(
                color: _colors['fg'],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${_customDocuments.length}/5',
              style: TextStyle(
                color: _colors['muted'],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upload up to 5 custom documents. These can be used instead of or in addition to the verification documents above.',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        // Display existing custom documents
        ...List.generate(_customDocuments.length, (index) {
          return _buildCustomDocumentTile(index);
        }),
        // Add new document button
        if (_customDocuments.length < 5) _buildAddCustomDocumentButton(),
      ],
    );
  }

  Widget _buildCustomDocumentTile(int index) {
    final file = _customDocuments[index];
    final name = _customDocumentNames[index];
    final fileName = file.path.split('/').last;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _colors['bg'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.insert_drive_file,
            color: Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          name,
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
              'Custom document',
              style: TextStyle(
                color: _colors['muted'],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fileName,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.visibility, color: _colors['accent'], size: 20),
              onPressed: () => _showDocumentPreview(file, name),
              tooltip: 'Preview document',
            ),
            IconButton(
              icon: Icon(Icons.edit, color: _colors['accent'], size: 20),
              onPressed: () => _pickFile('customDocument', customIndex: index),
              tooltip: 'Replace document',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _removeCustomDocument(index),
              tooltip: 'Remove document',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomDocumentButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _colors['bg'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _colors['border']!,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _colors['accent']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.add,
            color: _colors['accent'],
            size: 20,
          ),
        ),
        title: Text(
          'Add Custom Document',
          style: TextStyle(
            color: _colors['fg'],
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          'Upload additional supporting documents',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.upload_file,
          color: _colors['accent'],
          size: 20,
        ),
        onTap: () => _pickFile('customDocument'),
      ),
    );
  }

  void _removeCustomDocument(int index) {
    setState(() {
      _customDocuments.removeAt(index);
      _customDocumentNames.removeAt(index);
    });
  }

  void _showDocumentPreview(File file, String title) {
    final fileName = file.path.split('/').last.toLowerCase();
    final fileExtension = fileName.split('.').last;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: _colors['bg'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _colors['bg'],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: _colors['border']!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(fileExtension),
                      color: _colors['accent'],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: _colors['fg'],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            fileName,
                            style: TextStyle(
                              color: _colors['muted'],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: _colors['muted']),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: _buildFilePreviewContent(file, fileExtension),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _colors['bg'],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(color: _colors['border']!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'File size: ${_getFileSizeString(file)}',
                        style: TextStyle(
                          color: _colors['muted'],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // You could add functionality to open with external app here
                      },
                      icon: Icon(Icons.open_in_new, color: _colors['accent']),
                      label: Text(
                        'Open Externally',
                        style: TextStyle(color: _colors['accent']),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreviewContent(File file, String fileExtension) {
    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      return _buildImagePreview(file);
    } else if (['pdf', 'doc', 'docx'].contains(fileExtension)) {
      return _buildDocumentPreview(file, fileExtension);
    } else {
      return _buildUnsupportedFilePreview(fileExtension);
    }
  }

  Widget _buildImagePreview(File file) {
    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        child: Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 64,
                  color: _colors['muted'],
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load image',
                  style: TextStyle(
                    color: _colors['muted'],
                    fontSize: 16,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(File file, String fileExtension) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getFileIcon(fileExtension),
          size: 64,
          color: _colors['accent'],
        ),
        const SizedBox(height: 16),
        Text(
          'Document Preview',
          style: TextStyle(
            color: _colors['fg'],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preview not available for ${fileExtension.toUpperCase()} files',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'File: ${file.path.split('/').last}',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUnsupportedFilePreview(String fileExtension) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.insert_drive_file,
          size: 64,
          color: _colors['muted'],
        ),
        const SizedBox(height: 16),
        Text(
          'Preview Not Available',
          style: TextStyle(
            color: _colors['fg'],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'File type ${fileExtension.toUpperCase()} is not supported for preview',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSizeString(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  Widget _buildContactInformationCard() {
    return _buildCard(
      title: 'Contact Information',
      icon: Icons.contact_mail,
      children: [
        Text(
          'Request help from a campus moderator to assist with your verification:',
          style: TextStyle(
            color: _colors['muted'],
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Campus Moderator Assistance',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Campus moderators can help verify your society and assist with the verification process. Select a moderator to request their assistance.',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedModerator,
          decoration:
              _buildInputDecoration('Request Help from Campus Moderator'),
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
          onChanged: _isUpdateMode && _selectedModerator != null
              ? null // Disable if already assigned in update mode
              : (value) {
                  setState(() {
                    _selectedModerator = value;
                    _updateRequirement('moderatorRequest', value != null);
                  });
                },
        ),
        if (_isUpdateMode && _selectedModerator != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.lock, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Moderator assignment cannot be changed after submission.',
                  style: TextStyle(
                    color: _colors['muted'],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
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
                _getSubmitButtonText(),
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
